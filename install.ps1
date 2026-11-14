<#
.SYNOPSIS
Installs flamegold and yuhina as Typst local packages.

.DESCRIPTION
Creates one directory junction per package under
%APPDATA%\typst\packages\local\<name>\<version>, pointing at the clone, so that
documents can import @local/flamegold:<version> and @local/yuhina:<version>.

The name and version come from each clone's typst.toml, so the junction folder
always matches the manifest. Changes inside a clone take effect immediately,
and creating a junction needs no administrator rights.

yuhina is expected in a clone next to this repository (..\yuhina). If that
folder does not exist, it is cloned there with git.

flamegold loads citrus from its citrus submodule. If the submodule has not
been checked out, the script runs git submodule update --init for it.

Running the script again is safe: a junction that already points at the right
clone is left alone. A real folder is never deleted.

.PARAMETER YuhinaPath
Path of the yuhina clone. Default: a "yuhina" folder next to this repository.

.PARAMETER PackageRoot
Typst local package directory. Default: %APPDATA%\typst\packages\local.

.PARAMETER Force
Replace a junction that points somewhere else. Only the junction is removed,
never the folder it points to.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\install.ps1
#>
#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$YuhinaPath,
    [string]$PackageRoot,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

if (-not $PackageRoot) {
    if (-not $env:APPDATA) {
        throw 'APPDATA is not set. This script is meant for Windows; pass -PackageRoot to choose the directory.'
    }
    $PackageRoot = Join-Path $env:APPDATA 'typst\packages\local'
}
if (-not $YuhinaPath) {
    $YuhinaPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'yuhina'
}

# Reads a string value such as name = "x" from the [package] table of a clone's typst.toml.
function Get-ManifestValue {
    param([string]$Dir, [string]$Key)

    $manifest = Join-Path $Dir 'typst.toml'
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw "typst.toml not found in $Dir"
    }
    $pattern = '^\s*' + $Key + '\s*=\s*"([^"]+)"'
    foreach ($line in Get-Content -LiteralPath $manifest) {
        $m = [regex]::Match($line, $pattern)
        if ($m.Success) { return $m.Groups[1].Value }
    }
    throw "No $Key found in $manifest"
}

# Returns the normalized target of a junction, or $null.
function Get-LinkTarget {
    param($Item)

    $target = @($Item.Target)[0]
    if (-not $target) { return $null }
    $target = $target -replace '^\\\?\?\\', ''
    return [System.IO.Path]::GetFullPath($target).TrimEnd('\', '/')
}

function Install-TypstPackage {
    param([string]$Source)

    $src = (Resolve-Path -LiteralPath $Source).ProviderPath.TrimEnd('\', '/')
    $name = Get-ManifestValue $src 'name'
    $version = Get-ManifestValue $src 'version'
    $parent = Join-Path $PackageRoot $name
    $link = Join-Path $parent $version

    $item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
    if ($item) {
        if (-not $item.LinkType) {
            throw "$link already exists and is a real folder, not a junction. Move or delete it yourself, then run this script again."
        }
        $current = Get-LinkTarget $item
        if ($current -ieq $src) {
            Write-Host "ok       @local/${name}:$version (already linked)"
            return
        }
        if (-not $Force) {
            throw "$link is a junction to $current, not to $src. Run the script with -Force to replace it."
        }
        # Deleting the item removes only the junction, never the folder it points to.
        $item.Delete()
    }

    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    New-Item -ItemType Junction -Path $link -Target $src | Out-Null
    Write-Host "linked   @local/${name}:$version -> $src"
}

if (-not (Test-Path -LiteralPath $YuhinaPath)) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "yuhina was not found at $YuhinaPath and git is not available to clone it. Install git, or pass -YuhinaPath."
    }
    Write-Host "cloning  yuhina -> $YuhinaPath"
    # Windows PowerShell 5.1 turns any stderr output of a native command into an error
    # while $ErrorActionPreference is 'Stop', so check the exit code instead.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    git clone --quiet https://github.com/zhenhuang-tw/yuhina.git $YuhinaPath
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $previous
    if ($exitCode -ne 0) { throw 'git clone failed.' }
}
if ((Get-ManifestValue $YuhinaPath 'name') -ne 'yuhina') {
    throw "$YuhinaPath is not a yuhina clone (its typst.toml names another package)."
}

# The citrus submodule is empty when the repository was cloned without
# --recurse-submodules; flamegold cannot compile without it.
if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'citrus\lib.typ') -PathType Leaf)) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw 'The citrus submodule is not checked out and git is not available. Install git, then run this script again.'
    }
    Write-Host 'checkout citrus submodule'
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    git -C $PSScriptRoot submodule update --init --quiet citrus
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $previous
    if ($exitCode -ne 0) { throw 'git submodule update failed.' }
}

# yuhina first, because flamegold imports it.
Install-TypstPackage $YuhinaPath
Install-TypstPackage $PSScriptRoot

Write-Host 'Done.'
