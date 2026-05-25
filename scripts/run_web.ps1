param(
  [string]$Device = "chrome"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot

& (Join-Path $PSScriptRoot "ensure_api_running.ps1") -Restart

Set-Location $projectRoot
flutter run -d $Device
