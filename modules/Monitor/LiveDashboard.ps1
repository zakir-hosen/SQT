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

            # If connected, collect CPU and Memory metrics (others will be implemented next)
            if ($isConnected -and $deviceToken) {
                $devNorm = if ($deviceToken -match ':') { $deviceToken.Split(':')[0] } else { $deviceToken }
                try {
                    $cpuVal = Get-SQTCPUUsage -Device $devNorm
                    if ($null -ne $cpuVal) { $cpu = "${cpuVal}" } else { $cpu = "N/A" }
                }
                catch {
                    $cpu = "N/A"
                }

                try {
                    $memVal = Get-SQTMemoryUsage -Device $devNorm
                    if ($null -ne $memVal) { $memory = "${memVal}" } else { $memory = "N/A" }
                }
                catch {
                    $memory = "N/A"
                }
            }

            # Render the dashboard without clearing the whole screen to minimize flicker
            try {
                if (-not $Script:LiveDashboardLastHeight) { $Script:LiveDashboardLastHeight = 0 }

                # Clear the previously rendered region (if any) to avoid leftover characters
                for ($i = 0; $i -lt $Script:LiveDashboardLastHeight; $i++) {
                    try {
                        [System.Console]::SetCursorPosition(0, $i)
                        $pad = ' ' * [System.Console]::WindowWidth
                        Write-Host $pad -NoNewline
                    }
                    catch {
                        # ignore errors if the console size changed
                    }
                }

                [System.Console]::SetCursorPosition(0, 0)
            }
            catch {
                # If console operations fail, fallback to full clear
                Clear-Host
            }

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
            # CPU with colorized value
            $cpuNum = $null
            if ([double]::TryParse($cpu, [ref]$cpuNum)) {
                if ($cpuNum -lt 50) { $cpuColor = 'Green' }
                elseif ($cpuNum -lt 80) { $cpuColor = 'Yellow' }
                else { $cpuColor = 'Red' }
                Write-Host "  CPU %       : " -NoNewline; Write-Host "${cpuNum}%" -ForegroundColor $cpuColor
            }
            else {
                Write-Host "  CPU %       : $cpu"
            }

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

            # Capture final cursor position to know how many lines were rendered
            try {
                $Script:LiveDashboardLastHeight = [System.Console]::CursorTop
            }
            catch {
                # ignore
            }

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
# Implemented metric collectors (step 1: CPU usage)
# - Get-SQTCPUUsage: reads /proc/stat twice and computes CPU utilization
#   between samples. Uses Invoke-SQTShell to read remote /proc/stat.
# ------------------------------------------------------------

function Get-SQTCPUUsage {
    param(
        [Parameter(Mandatory = $true)][string]$Device
    )

    # Normalize device (strip :port if present)
    if ($Device -match ':' ) { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        # Helper to read cpu line
        $readCpu = {
            param($d)
            $line = Invoke-SQTShell $d "cat /proc/stat | grep '^cpu '" 2>$null
            if (-not $line) { return $null }
            $text = ($line -join "`n") -replace "^cpu\s+", ""
            $parts = $text -split '\s+' | Where-Object { $_ -ne '' }
            # fields: user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice
            [long]$user = 0; [long]$nice = 0; [long]$system = 0; [long]$idle = 0; [long]$iowait = 0; [long]$irq = 0; [long]$softirq = 0; [long]$steal = 0
            if ($parts.Count -ge 1) { [long]$user = [long]$parts[0] }
            if ($parts.Count -ge 2) { [long]$nice = [long]$parts[1] }
            if ($parts.Count -ge 3) { [long]$system = [long]$parts[2] }
            if ($parts.Count -ge 4) { [long]$idle = [long]$parts[3] }
            if ($parts.Count -ge 5) { [long]$iowait = [long]$parts[4] }
            if ($parts.Count -ge 6) { [long]$irq = [long]$parts[5] }
            if ($parts.Count -ge 7) { [long]$softirq = [long]$parts[6] }
            if ($parts.Count -ge 8) { [long]$steal = [long]$parts[7] }

            $idleAll = $idle + $iowait
            $nonIdle = $user + $nice + $system + $irq + $softirq + $steal
            $total = $idleAll + $nonIdle

            return [PSCustomObject]@{ Total = $total; Idle = $idleAll }
        }

        $s1 = & $readCpu $dev
        if (-not $s1) { return $null }

        Start-Sleep -Milliseconds 300

        $s2 = & $readCpu $dev
        if (-not $s2) { return $null }

        $deltaTotal = $s2.Total - $s1.Total
        $deltaIdle = $s2.Idle - $s1.Idle

        if ($deltaTotal -le 0) { return 0 }

        $usage = (1 - ($deltaIdle / $deltaTotal)) * 100
        return [math]::Round($usage, 1)
    }
    catch {
        return $null
    }
}

# Implement Get-SQTMemoryUsage - reads /proc/meminfo and returns used memory in MB
function Get-SQTMemoryUsage {
    param(
        [Parameter(Mandatory = $true)][string]$Device
    )

    # Normalize device token
    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        # Read MemTotal and MemAvailable
        $lines = Invoke-SQTShell $dev "cat /proc/meminfo | grep -E 'MemTotal|MemAvailable'" 2>$null
        if (-not $lines) { return $null }

        $totalKb = 0
        $availKb = 0

        foreach ($l in $lines) {
            if ($l -match 'MemTotal:\s*(\d+)') { $totalKb = [int]$matches[1] }
            if ($l -match 'MemAvailable:\s*(\d+)') { $availKb = [int]$matches[1] }
        }

        if ($totalKb -le 0) { return $null }

        $usedKb = $totalKb - $availKb
        $usedMb = [math]::Round(($usedKb / 1024), 1)

        return $usedMb
    }
    catch {
        return $null
    }
}

function Get-SQTThreadCount { param([string]$Device) throw "Not implemented" }
function Get-SQTLoadAverage { param([string]$Device) throw "Not implemented" }
function Get-SQTBatteryInfo { param([string]$Device) throw "Not implemented" }
function Get-SQTTemperature { param([string]$Device) throw "Not implemented" }
function Get-SQTWifiInfo { param([string]$Device) throw "Not implemented" }
function Get-SQTStorageInfo { param([string]$Device) throw "Not implemented" }
function Get-SQTLastErrors { param([string]$Device, [int]$Lines = 50) throw "Not implemented" }

# End of file
