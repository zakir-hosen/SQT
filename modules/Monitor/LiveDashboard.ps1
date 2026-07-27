# ============================================================
# Sicunet QA Toolkit
# Live Dashboard (incremental scaffold)
# modules/Monitor/LiveDashboard.ps1
# ============================================================

# NOTE:
# This file provides an incremental, production-oriented scaffold for the
# Live Dashboard feature. It implements the main UI loop (Show-SQTLiveDashboard)
# and a small connectivity helper (Get-SQTIsDeviceConnected). Additional
# metric collectors (CPU, Memory, Battery, etc.) will be implemented one at
# a time as requested.

# ------------------------------------------------------------
# Show-SQTLiveDashboard
# - main entrypoint for the dashboard UI
# - refreshes at the requested interval (default: 1s)
# - press Q to quit
# - minimizes flicker by re-writing from the top using Console.SetCursorPosition
# ------------------------------------------------------------
function Show-SQTLiveDashboard {

    param(
        [int]$IntervalSeconds = 1
    )

    # Validate interval
    if ($IntervalSeconds -lt 1) { $IntervalSeconds = 1 }

    try {
        # Load configuration and helpers from common if available
        if (Get-Command Get-SQTConfig -ErrorAction SilentlyContinue) {
            $config = Get-SQTConfig
        }
        else {
            $config = $null
        }

        # Initial screen setup
        Clear-Host
        Write-Host "==========================================================" -ForegroundColor Cyan
        Write-Host "               SICUNET QA TOOLKIT - LIVE DASHBOARD" -ForegroundColor Cyan
        Write-Host "==========================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Loading..." -ForegroundColor Yellow
        Write-Host "(Press Q to quit)" -ForegroundColor DarkGray

        # Give the UI a moment to render
        Start-Sleep -Milliseconds 200

        $quit = $false

        # Use a consistent buffer height to avoid visual jumps
        while (-not $quit) {

            # Check for keypress first (non-blocking)
            if ([System.Console]::KeyAvailable) {
                $key = [System.Console]::ReadKey($true)
                if ($key.Key -eq [System.ConsoleKey]::Q) {
                    $quit = $true
                    break
                }
            }

            # Collect data (use lightweight calls here; each metric will be implemented separately)
            try {
                $config = Get-SQTConfig
            }
            catch {
                $config = $null
            }

            $deviceToken = $null
            $isConnected = $false
            try {
                $conn = Get-SQTIsDeviceConnected -Config $config
                if ($conn) {
                    $isConnected = $conn.IsConnected
                    $deviceToken = $conn.DeviceToken
                }
            }
            catch {
                # ignore - fall back to disconnected
                $isConnected = $false
                $deviceToken = $null
            }

            # Prepare display values (placeholders until metrics implemented)
            $deviceStatus = if ($isConnected) { "Connected ($deviceToken)" } else { "Not Connected" }

            $appStatus = "Loading..."
            $appPid = "-"

            $cpu = "Loading..."
            $memory = "Loading..."
            $threads = "-"
            $loadAvg = "-"

            $battery = "-"
            $temp = "-"
            $storage = "-"
            $wifi = "-"

            $ip = "-"
            $internet = "-"
            $cloud = "-"

            $errorCount = "-"
            $warningCount = "-"
            $lastError = "-"

            $currentTime = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
            $adbVersion = "-"
            $androidVersion = "-"

            # Render the dashboard without clearing the whole screen to minimize flicker
            [System.Console]::SetCursorPosition(0, 0)

            # Top header (overwrite previous content)
            Write-Host "==========================================================" -ForegroundColor Cyan
            Write-Host "               SICUNET QA TOOLKIT - LIVE DASHBOARD" -ForegroundColor Cyan
            Write-Host "==========================================================" -ForegroundColor Cyan
            Write-Host ""

            # Device
            Write-Host "Device:" -ForegroundColor Green
            if ($isConnected) {
                Write-Host "  Connection Status : " -NoNewline; Write-Host $deviceStatus -ForegroundColor Green
            }
            else {
                Write-Host "  Connection Status : " -NoNewline; Write-Host $deviceStatus -ForegroundColor Red
            }
            Write-Host ""

            # Application
            Write-Host "Application:" -ForegroundColor Green
            Write-Host "  Status : $appStatus"
            Write-Host "  PID    : $appPid"
            Write-Host ""

            # Performance
            Write-Host "Performance" -ForegroundColor Green
            Write-Host "  CPU %       : $cpu"
            Write-Host "  Memory MB    : $memory"
            Write-Host "  Thread Count : $threads"
            Write-Host "  Load Average : $loadAvg"
            Write-Host ""

            # Device info
            Write-Host "Device" -ForegroundColor Green
            Write-Host "  Battery %   : $battery"
            Write-Host "  Temperature  : $temp"
            Write-Host "  Storage %    : $storage"
            Write-Host "  WiFi RSSI    : $wifi"
            Write-Host ""

            # Network
            Write-Host "Network" -ForegroundColor Green
            Write-Host "  IP           : $ip"
            Write-Host "  Internet     : $internet"
            Write-Host "  Cloud Status : $cloud"
            Write-Host ""

            # Logs
            Write-Host "Logs" -ForegroundColor Green
            Write-Host "  Error Count   : $errorCount"
            Write-Host "  Warning Count : $warningCount"
            Write-Host "  Last Error    : $lastError"
            Write-Host ""

            # System
            Write-Host "System" -ForegroundColor Green
            Write-Host "  Current Time  : $currentTime"
            Write-Host "  ADB Version   : $adbVersion"
            Write-Host "  Android Ver.  : $androidVersion"
            Write-Host ""

            Write-Host "(Press Q to quit)" -ForegroundColor DarkGray

            # Wait for interval while still allowing key polling
            $sleepStep = 100
            $elapsed = 0
            while ($elapsed -lt ($IntervalSeconds * 1000)) {
                Start-Sleep -Milliseconds $sleepStep
                $elapsed += $sleepStep
                if ([System.Console]::KeyAvailable) {
                    $k = [System.Console]::ReadKey($true)
                    if ($k.Key -eq [System.ConsoleKey]::Q) {
                        $quit = $true
                        break
                    }
                }
            }

        }

        # Clear the UI area before exit
        Clear-Host
        Write-Host "Live Dashboard exited." -ForegroundColor Yellow

    }
    catch {
        Write-SQTLog "Live dashboard failed: $($_.Exception.Message)" "ERROR"
    }

}

# ------------------------------------------------------------
# Get-SQTIsDeviceConnected
# - helper that checks currently connected adb devices and
#   returns a small object with IsConnected and DeviceToken
# ------------------------------------------------------------
function Get-SQTIsDeviceConnected {

    param(
        [Parameter()]
        $Config
    )

    # Returns $null on failure or a PSCustomObject: @{ IsConnected = bool; DeviceToken = 'ip' }
    try {
        if (-not $Config) { $Config = Get-SQTConfig }
    }
    catch {
        $Config = $null
    }

    try {
        $connected = @(Get-SQTConnectedDevices)
    }
    catch {
        return $null
    }

    if ($connected.Count -eq 0) {
        return @{ IsConnected = $false; DeviceToken = $null }
    }

    $currentToken = $null
    if ($Config -and $Config.CurrentDevice) {
        $currentToken = $Config.CurrentDevice
    }

    # Parse tokens (first column)
    $items = @()
    foreach ($line in $connected) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $token = ($line -split '\s+')[0]
        $items += $token
    }

    if ($currentToken) {
        foreach ($t in $items) {
            if ($t -like "*$currentToken*") {
                return @{ IsConnected = $true; DeviceToken = $t }
            }
        }
    }

    # Return first connected device if current not matched
    return @{ IsConnected = $true; DeviceToken = $items[0] }

}

# ------------------------------------------------------------
# Stubs for metric collectors (to be implemented one-by-one)
# - Get-SQTCPUUsage
# - Get-SQTMemoryUsage
# - Get-SQTThreadCount
# - Get-SQTLoadAverage
# - Get-SQTBatteryInfo
# - Get-SQTTemperature
# - Get-SQTWifiInfo
# - Get-SQTStorageInfo
# - Get-SQTLastErrors
#
# Each will be implemented in subsequent steps. They should use
# Invoke-SQTShell / Invoke-SQTADB and follow the project's helper
# conventions.
# ------------------------------------------------------------

function Get-SQTCPUUsage { param([string]$Device) throw "Not implemented" }
function Get-SQTMemoryUsage { param([string]$Device) throw "Not implemented" }
function Get-SQTThreadCount { param([string]$Device) throw "Not implemented" }
function Get-SQTLoadAverage { param([string]$Device) throw "Not implemented" }
function Get-SQTBatteryInfo { param([string]$Device) throw "Not implemented" }
function Get-SQTTemperature { param([string]$Device) throw "Not implemented" }
function Get-SQTWifiInfo { param([string]$Device) throw "Not implemented" }
function Get-SQTStorageInfo { param([string]$Device) throw "Not implemented" }
function Get-SQTLastErrors { param([string]$Device, [int]$Lines = 50) throw "Not implemented" }

# End of file
