<#
.SYNOPSIS
    Installs the Breeze Dark style into the TeamSpeak 3 configuration (Windows).

.DESCRIPTION
    Copies Breeze.qss, Breeze_chat.qss and the templates to
    %APPDATA%\TS3Client\styles\. With -Icons the dark-friendly icon pack is
    built and placed as well (requires Python 3).

.PARAMETER Icons
    Also build the icon pack.

.PARAMETER ConfigPath
    Alternative configuration folder, for example with a portable installation
    (there the configuration lives in the program folder, not %APPDATA%).

.EXAMPLE
    .\install.ps1 -Icons

.EXAMPLE
    .\install.ps1 -ConfigPath "D:\TeamSpeak3"
#>

[CmdletBinding()]
param(
    [switch]$Icons,
    [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- Determine the target folder -------------------------------------------
if ($ConfigPath) {
    $ts3 = $ConfigPath
} else {
    $ts3 = Join-Path $env:APPDATA 'TS3Client'
}

if (-not (Test-Path $ts3)) {
    Write-Error @"
No TeamSpeak 3 configuration folder found: $ts3

Start TeamSpeak once so the folder gets created, or point at the program folder
if you use a portable installation:
    .\install.ps1 -ConfigPath "D:\TeamSpeak3"
"@
}

Write-Host "Target folder: $ts3"

# --- Copy the style --------------------------------------------------------
$stylesDir = Join-Path $ts3 'styles'
$breezeDir = Join-Path $stylesDir 'Breeze'
New-Item -ItemType Directory -Force -Path $breezeDir | Out-Null

Copy-Item (Join-Path $repo 'styles\Breeze.qss')      $stylesDir -Force
Copy-Item (Join-Path $repo 'styles\Breeze_chat.qss') $stylesDir -Force
Copy-Item (Join-Path $repo 'styles\Breeze\*.tpl')    $breezeDir -Force

Write-Host 'Style installed (Breeze.qss, Breeze_chat.qss, 5 templates)'

# --- Icon pack (optional) --------------------------------------------------
if ($Icons) {
    Write-Host ''
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) { $python = Get-Command python3 -ErrorAction SilentlyContinue }
    if (-not $python) {
        Write-Warning 'Python 3 not found - icon pack skipped. See README.'
    } else {
        & $python.Source (Join-Path $repo 'tools\build-iconpack.py') --install
    }
}

Write-Host ''
Write-Host 'Done. Now in TeamSpeak:'
Write-Host ''
Write-Host '  1. Quit the client completely and restart it'
Write-Host '     (palette values are only read at startup)'
Write-Host '  2. Tools -> Options -> Design -> Style: Breeze'
if ($Icons) {
    Write-Host '  3. Tools -> Options -> Design -> Icon pack: breeze_dark_mono'
}
