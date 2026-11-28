<#
.SYNOPSIS
Installs flamegold as a Typst local package.

.DESCRIPTION
Creates a directory junction at
%APPDATA%\typst\packages\local\<name>\<version>, pointing at this clone, so
that documents can import @local/flamegold:<version>.

The name and version come from the clone's typst.toml, so the junction folder
always matches the manifest. Changes inside the clone take effect immediately,
and creating a junction needs no administrator rights.

yuhina is not installed here: flamegold imports @preview/yuhina from Typst
Universe, which Typst downloads on first compile.

Running the script again is safe: a junction that already points at the right
clone is left alone. A real folder is never deleted.

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

Install-TypstPackage $PSScriptRoot

Write-Host 'Done.'
