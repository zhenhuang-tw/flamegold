<#
.SYNOPSIS
Updates the vendored copy of citrus in lib\citrus.

.DESCRIPTION
flamegold ships citrus as plain files, because packages on Typst Universe
cannot use Git submodules. This script does by hand what
"git submodule update" used to do:

  1. Shallow-clone the fork into a fresh temporary folder.
  2. Replace lib\citrus\src, lib.typ and LICENSE with the cloned files.
     Only these runtime files are copied; tests, examples, fonts and the
     docs site stay out of the package.
  3. Write the new commit hash and citrus version into lib\citrus\VENDORED.md.
  4. Delete the temporary folder, even if a step failed.

The script never commits. Review the result with "git status" and
"git diff --stat", then commit it yourself.

It stops before touching anything if lib\citrus has uncommitted changes,
because those changes would be overwritten. Pass -Force to overwrite them.

This file is ASCII only, so Windows PowerShell 5.1 reads it correctly
whatever the system code page is.

.PARAMETER Branch
Branch of the fork to copy. Default: ntu-adapted.

.PARAMETER Url
Clone URL of the fork. Default: https://github.com/zhenhuang-tw/citeproc-typst.git

.PARAMETER Force
Overwrite uncommitted changes in lib\citrus.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\scripts\update-citrus.ps1

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\scripts\update-citrus.ps1 -Branch fix/some-branch
#>
#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Branch = 'ntu-adapted',
    [string]$Url = 'https://github.com/zhenhuang-tw/citeproc-typst.git',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "[update-citrus] $Message"
}

# Prints what went wrong and an optional hint, then stops the script with
# exit code 1. "exit" rather than "throw", so the message above is not
# buried under PowerShell's own red error record; any pending finally
# block (the temp folder cleanup) still runs.
function Stop-WithError {
    param([string]$Message, [string[]]$Detail, [string]$Hint)

    Write-Host "[update-citrus] ERROR: $Message" -ForegroundColor Red
    foreach ($line in $Detail) {
        if ($line) { Write-Host "    $line" -ForegroundColor Red }
    }
    if ($Hint) { Write-Host "[update-citrus] HINT: $Hint" -ForegroundColor Yellow }
    exit 1
}

# Runs git and returns its output as strings. git writes progress and
# warnings to stderr; under 'Stop', Windows PowerShell 5.1 would turn
# those lines into terminating errors, so 'Continue' is used while git
# runs and the exit code decides success instead.
function Invoke-Git {
    param([string[]]$Arguments, [string]$What)

    Write-Verbose ("git " + ($Arguments -join ' '))
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git @Arguments 2>&1 | ForEach-Object { "$_" }
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previous
    }
    if ($exitCode -ne 0) {
        $detail = @(("command: git " + ($Arguments -join ' ')), "exit code: $exitCode") + @($output)
        Stop-WithError -Message "$What failed." -Detail $detail
    }
    return $output
}

# Reads and writes UTF-8 without BOM. Get-Content and Set-Content in
# Windows PowerShell 5.1 would guess the encoding or add a BOM.
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Read-Utf8 {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path, $utf8NoBom)
}

function Write-Utf8 {
    param([string]$Path, [string]$Text)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

# --- Check the environment -------------------------------------------------

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Stop-WithError -Message 'git was not found in PATH.' `
        -Hint 'Install Git for Windows, open a new terminal, and run this script again.'
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$target = Join-Path (Join-Path $repoRoot 'lib') 'citrus'
$vendored = Join-Path $target 'VENDORED.md'

Write-Step "repository: $repoRoot"
Write-Step "target:     $target"

if (-not (Test-Path -LiteralPath $vendored -PathType Leaf)) {
    Stop-WithError -Message "$vendored was not found." `
        -Hint 'Run this script from a flamegold clone; it must stay in the scripts folder.'
}

$status = Invoke-Git -Arguments @('-C', $repoRoot, 'status', '--porcelain', '--', 'lib/citrus') `
    -What 'Checking lib\citrus for uncommitted changes'
if ($status) {
    if ($Force) {
        Write-Step 'WARNING: lib\citrus has uncommitted changes; -Force was given, so they will be overwritten.'
    } else {
        Stop-WithError -Message 'lib\citrus has uncommitted changes, which this script would overwrite.' `
            -Detail $status `
            -Hint 'Commit or discard them ("git restore lib/citrus"), or run again with -Force.'
    }
}

# The hash and version are found by ASCII patterns, so this script needs
# no non-ASCII text. Each must occur exactly once in VENDORED.md.
$hashPattern = '`[0-9a-f]{40}`'
$versionPattern = 'citrus \d+\.\d+\.\d+'

$text = Read-Utf8 $vendored
$hashMatches = [regex]::Matches($text, $hashPattern)
$versionMatches = [regex]::Matches($text, $versionPattern)
if ($hashMatches.Count -ne 1) {
    Stop-WithError -Message "VENDORED.md must contain exactly one commit hash in backticks; found $($hashMatches.Count)." `
        -Hint 'Restore the "source commit" line, e.g. with "git restore lib/citrus/VENDORED.md".'
}
if ($versionMatches.Count -ne 1) {
    Stop-WithError -Message "VENDORED.md must contain exactly one 'citrus X.Y.Z'; found $($versionMatches.Count)." `
        -Hint 'Restore the "upstream version" line, e.g. with "git restore lib/citrus/VENDORED.md".'
}
$oldHash = $hashMatches[0].Value.Trim('`')
Write-Step "current commit: $oldHash ($($versionMatches[0].Value))"

# --- Clone into a fresh temporary folder -----------------------------------

# A new random name each run, so a folder left over from an earlier run
# can never be mistaken for a fresh clone.
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('citrus-' + [System.IO.Path]::GetRandomFileName())

try {
    Write-Step "cloning $Url (branch $Branch)"
    Write-Step "  into $tmp"
    Invoke-Git -Arguments @('clone', '--quiet', '--depth', '1', '--branch', $Branch, $Url, $tmp) `
        -What 'Cloning the fork' | Out-Null

    $newHash = (Invoke-Git -Arguments @('-C', $tmp, 'rev-parse', 'HEAD') -What 'Reading the cloned commit') |
        Select-Object -First 1
    $subject = (Invoke-Git -Arguments @('-C', $tmp, 'log', '-1', '--format=%s') -What 'Reading the commit subject') |
        Select-Object -First 1
    Write-Step "cloned commit:  $newHash"
    Write-Step "  $subject"

    foreach ($name in @('lib.typ', 'src', 'LICENSE', 'typst.toml')) {
        if (-not (Test-Path -LiteralPath (Join-Path $tmp $name))) {
            Stop-WithError -Message "The clone has no $name." `
                -Hint "Check that branch $Branch of $Url is a citrus repository."
        }
    }

    $manifest = Read-Utf8 (Join-Path $tmp 'typst.toml')
    $versionMatch = [regex]::Match($manifest, '(?m)^\s*version\s*=\s*"([^"]+)"')
    if (-not $versionMatch.Success) {
        Stop-WithError -Message 'No version found in the cloned typst.toml.'
    }
    $newVersion = $versionMatch.Groups[1].Value
    Write-Step "cloned version: citrus $newVersion"

    if ($newHash -eq $oldHash -and -not $status) {
        Write-Step 'lib\citrus is already at this commit; nothing to do.'
        return
    }

    # --- Replace the files -------------------------------------------------

    # src is deleted first so that files removed or renamed upstream do not
    # linger in the copy.
    try {
        $oldSrc = Join-Path $target 'src'
        if (Test-Path -LiteralPath $oldSrc) {
            Write-Step 'removing lib\citrus\src'
            Remove-Item -LiteralPath $oldSrc -Recurse -Force
        }
        foreach ($name in @('src', 'lib.typ', 'LICENSE')) {
            Write-Step "copying $name"
            Copy-Item -LiteralPath (Join-Path $tmp $name) -Destination $target -Recurse -Force
        }
    } catch {
        Stop-WithError -Message 'Replacing the files in lib\citrus failed; the copy may be incomplete.' `
            -Detail @($_.Exception.Message) `
            -Hint 'Undo with "git restore lib/citrus" and "git clean -fd lib/citrus", then run again.'
    }

    # --- Record the new commit ---------------------------------------------

    $text = $text -replace $hashPattern, ('`' + $newHash + '`')
    $text = $text -replace $versionPattern, "citrus $newVersion"
    Write-Utf8 $vendored $text
    Write-Step 'updated commit and version in VENDORED.md'

    $count = @(Get-ChildItem -LiteralPath (Join-Path $target 'src') -Recurse -File).Count
    Write-Host ''
    Write-Step "done: $oldHash -> $newHash ($count files in src)"
    Write-Step 'next: review with "git status" and "git diff --stat lib/citrus", then commit, e.g.'
    Write-Host "    git add lib/citrus"
    Write-Host "    git commit -m `"build(deps): update vendored citrus to $($newHash.Substring(0, 7))`""
} finally {
    if (Test-Path -LiteralPath $tmp) {
        Write-Verbose "removing $tmp"
        # git marks pack files read-only; -Force removes them anyway.
        Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath $tmp) {
            Write-Step "WARNING: could not delete $tmp; delete it by hand."
        }
    }
}
