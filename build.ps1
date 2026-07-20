# EoS MegaMod build & deploy
# Zips MegaMod source (excluding Research/) and deploys to the Paradox launcher's Unmanaged mods folder.
# Usage: .\build.ps1          (build + deploy)
#        .\build.ps1 -NoDeploy (build only)
param([switch]$NoDeploy)

$ErrorActionPreference = "Stop"
$src     = Join-Path $PSScriptRoot "MegaMod"
$zip     = Join-Path $PSScriptRoot "EoS_MegaMod.zip"
$deploy  = Join-Path $env:USERPROFILE "AppData\LocalLow\Paradox Interactive\Empire of Sin\Mods\Unmanaged\EoS_MegaMod.zip"

# Sanity: the three World/ files must exist (they went missing once before — 2026-03-17)
$mustExist = @(
    "Raw~\Lua\World\Missions.lua",
    "Raw~\Lua\World\World.lua",
    "Raw~\Lua\World\Actors\Characters\Character.lua",
    "Raw~\Localization\EoS_MegaMod_en.json",
    "ModDescription.json"
)
foreach ($f in $mustExist) {
    if (-not (Test-Path (Join-Path $src $f))) { throw "MISSING REQUIRED FILE: $f — aborting build." }
}

if (Test-Path $zip) { Remove-Item $zip }

# Compress-Archive can't exclude subfolders, so stage ModDescription.json + Raw~ explicitly.
Compress-Archive -Path (Join-Path $src "ModDescription.json"), (Join-Path $src "Raw~") -DestinationPath $zip

$count = ([System.IO.Compression.ZipFile]::OpenRead($zip)).Entries.Count
Write-Host "Built $zip ($count entries)"

if (-not $NoDeploy) {
    Copy-Item $zip $deploy -Force
    Write-Host "Deployed to $deploy"
}
Write-Host "Reminder: smoke-test by grepping player.log for 'Unknown script key' / 'attempt to call a nil value'"
