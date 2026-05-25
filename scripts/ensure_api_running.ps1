param(
  [int]$Port = 3000,
  [int]$StartupTimeoutSec = 20,
  [switch]$Restart
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$apiDir = Join-Path $projectRoot "api"
$serverScript = Join-Path $apiDir "server.js"
$healthUrl = "http://localhost:$Port/api/meta/health"

function Get-PortOwnerPid {
  param([int]$LocalPort)

  $output = netstat -ano -p tcp | Select-String ":$LocalPort\s+.*LISTENING\s+\d+$" |
    Select-Object -First 1
  if (-not $output) {
    return $null
  }

  $line = $output.ToString().Trim()
  $parts = $line -split "\s+"
  if ($parts.Count -lt 5) {
    return $null
  }

  $pidValue = 0
  if ([int]::TryParse($parts[-1], [ref]$pidValue)) {
    return $pidValue
  }

  return $null
}

function Test-ApiReady {
  param([string]$Url)
  try {
    $null = Invoke-RestMethod -Method Get -Uri $Url -UseBasicParsing -TimeoutSec 3
    return $true
  } catch {
    return $false
  }
}

if (-not $Restart -and (Test-ApiReady -Url $healthUrl)) {
  Write-Host "API already running at $healthUrl"
  exit 0
}

$portOwnerPid = Get-PortOwnerPid -LocalPort $Port
if ($portOwnerPid -and $portOwnerPid -ne $PID) {
  try {
    Stop-Process -Id $portOwnerPid -Force -ErrorAction Stop
    Start-Sleep -Seconds 1
  } catch {
    throw "Port $Port is busy (PID=$portOwnerPid). Close that process, then run again."
  }
}

$startedProc = Start-Process `
  -FilePath "node" `
  -ArgumentList "server.js" `
  -WorkingDirectory $apiDir `
  -WindowStyle Hidden `
  -PassThru

Write-Host "Started API process PID=$($startedProc.Id) on port $Port."

$deadline = (Get-Date).AddSeconds($StartupTimeoutSec)
while ((Get-Date) -lt $deadline) {
  Start-Sleep -Milliseconds 600
  if (Test-ApiReady -Url $healthUrl) {
    Write-Host "API is ready: $healthUrl"
    exit 0
  }
  if ($startedProc.HasExited) {
    break
  }
}

throw "API is not ready. Port $Port may already be used by another process. Close old API process and run again."
