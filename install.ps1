<#
.SYNOPSIS
    Installiert den Breeze-Dark-Style in die TeamSpeak-3-Konfiguration (Windows).

.DESCRIPTION
    Kopiert Breeze.qss, Breeze_chat.qss und die Vorlagen nach
    %APPDATA%\TS3Client\styles\. Mit -Icons wird zusaetzlich das
    dunkeltaugliche Icon-Pack gebaut und abgelegt (benoetigt Python 3).

.PARAMETER Icons
    Zusaetzlich das Icon-Pack erzeugen.

.PARAMETER ConfigPath
    Abweichender Konfigurationsordner, etwa bei einer portablen Installation
    (dort liegt die Konfiguration im Programmordner statt unter %APPDATA%).

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

# --- Zielordner bestimmen --------------------------------------------------
if ($ConfigPath) {
    $ts3 = $ConfigPath
} else {
    $ts3 = Join-Path $env:APPDATA 'TS3Client'
}

if (-not (Test-Path $ts3)) {
    Write-Error @"
Kein TeamSpeak-3-Konfigurationsordner gefunden: $ts3

Starte TeamSpeak einmal, damit der Ordner angelegt wird, oder gib bei einer
portablen Installation den Programmordner an:
    .\install.ps1 -ConfigPath "D:\TeamSpeak3"
"@
}

Write-Host "Zielordner: $ts3"

# --- Style kopieren --------------------------------------------------------
$stylesDir = Join-Path $ts3 'styles'
$breezeDir = Join-Path $stylesDir 'Breeze'
New-Item -ItemType Directory -Force -Path $breezeDir | Out-Null

Copy-Item (Join-Path $repo 'styles\Breeze.qss')      $stylesDir -Force
Copy-Item (Join-Path $repo 'styles\Breeze_chat.qss') $stylesDir -Force
Copy-Item (Join-Path $repo 'styles\Breeze\*.tpl')    $breezeDir -Force

Write-Host 'Style installiert (Breeze.qss, Breeze_chat.qss, 5 Vorlagen)'

# --- Icon-Pack (optional) --------------------------------------------------
if ($Icons) {
    Write-Host ''
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) { $python = Get-Command python3 -ErrorAction SilentlyContinue }
    if (-not $python) {
        Write-Warning 'Python 3 nicht gefunden - Icon-Pack uebersprungen. Siehe README.'
    } else {
        & $python.Source (Join-Path $repo 'tools\build-iconpack.py') --install
    }
}

Write-Host ''
Write-Host 'Fertig. Jetzt in TeamSpeak:'
Write-Host ''
Write-Host '  1. Client komplett beenden und neu starten'
Write-Host '     (Palettenwerte werden nur beim Start gelesen)'
Write-Host '  2. Extras -> Optionen -> Design -> Style: Breeze'
if ($Icons) {
    Write-Host '  3. Extras -> Optionen -> Design -> Icon-Pack: breeze_dark_mono'
}
