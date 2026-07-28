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

            $devNorm = $null
            if ($deviceToken) {
                $devNorm = if ($deviceToken -match ':') { $deviceToken.Split(':')[0] } else { $deviceToken }
            }

            $appStatus = "Not configured"
            $appPid = "-"
            $package = $null

            if ($config -and -not [string]::IsNullOrWhiteSpace($config.Package)) {
                $package = $config.Package
            }
            elseif ($config -and -not [string]::IsNullOrWhiteSpace($config.PackageName)) {
                $package = $config.PackageName
            }
            elseif ($global:SQTSession -and -not [string]::IsNullOrWhiteSpace($global:SQTSession.Package)) {
                $package = $global:SQTSession.Package
            }

            if ($package -and $devNorm) {
                try {
                    # Resolve the package PID only when we have a valid device token.
                    $processId = Get-SQTAppProcessId -Device $devNorm -Package $package
                    if ([string]::IsNullOrWhiteSpace($processId)) {
                        $appStatus = "Not running"
                        $appPid = "-"
                    }
                    else {
                        $appStatus = "Running"
                        $appPid = $processId
                    }
                }
                catch {
                    $appStatus = "Unavailable"
                    $appPid = "-"
                }
            }
            elseif ($package) {
                $appStatus = "Device unavailable"
                $appPid = "-"
            }

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

            # If connected, collect batched metrics (CPU, Memory, Load) and other device data
            if ($isConnected -and $deviceToken) {
                $devNorm = if ($deviceToken -match ':') { $deviceToken.Split(':')[0] } else { $deviceToken }
                try {
                    $metrics = Get-SQTDeviceMetrics -Device $devNorm
                    if ($metrics) {
                        $cpuVal = $metrics.CPU
                        if (-not [string]::IsNullOrWhiteSpace([string]$cpuVal)) { $cpu = [string]$cpuVal } else { $cpu = "N/A" }

                        $memVal = $metrics.MemoryMB
                        if (-not [string]::IsNullOrWhiteSpace([string]$memVal)) { $memory = [string]$memVal } else { $memory = "N/A" }

                        $loadVal = $metrics.LoadAvg
                        if (-not [string]::IsNullOrWhiteSpace([string]$loadVal)) { $loadAvg = [string]$loadVal } else { $loadAvg = "-" }
                    }
                    else {
                        $cpu = "N/A"
                        $memory = "N/A"
                        $loadAvg = "-"
                    }
                }
                catch {
                    $cpu = "N/A"
                    $memory = "N/A"
                    $loadAvg = "-"
                }

                try {
                    $threads = Get-SQTThreadCount -Device $devNorm
                    if (-not [string]::IsNullOrWhiteSpace([string]$threads)) { $threads = [string]$threads } else { $threads = "-" }
                }
                catch {
                    $threads = "-"
                }

                try {
                    $battery = Get-SQTBatteryInfo -Device $devNorm
                }
                catch {
                    $battery = "-"
                }

                try {
                    $temp = Get-SQTTemperature -Device $devNorm
                }
                catch {
                    $temp = "-"
                }

                try {
                    $storage = Get-SQTStorageInfo -Device $devNorm
                }
                catch {
                    $storage = "-"
                }

                try {
                    $wifi = Get-SQTWifiInfo -Device $devNorm
                }
                catch {
                    $wifi = "-"
                }

                try {
                    $ip = Get-SQTDeviceIP -Device $devNorm
                }
                catch {
                    $ip = "-"
                }

                try {
                    $internet = Get-SQTInternetStatus -Device $devNorm
                }
                catch {
                    $internet = "-"
                }

                try {
                    $androidVersion = Get-SQTAndroidVersion -Device $devNorm
                    if (-not [string]::IsNullOrWhiteSpace($androidVersion)) { $androidVersion = $androidVersion.Trim() }
                }
                catch {
                    $androidVersion = "-"
                }

                try {
                    $logs = Get-SQTLastErrors -Device $devNorm -Lines 50
                    if ($logs) {
                        $errorCount = $logs.ErrorCount
                        $warningCount = $logs.WarningCount
                        $lastError = $logs.LastError
                    }
                }
                catch {
                    $errorCount = "-"
                    $warningCount = "-"
                    $lastError = "-"
                }
            }

            try {
                $adbVersionOutput = @(Invoke-SQTADB @("version"))
                $adbVersionText = ($adbVersionOutput -join ' ').Trim()
                if (-not [string]::IsNullOrWhiteSpace($adbVersionText)) {
                    $adbVersion = $adbVersionText
                }
            }
            catch {
                $adbVersion = "-"
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

                [System.Console]::SetCursorPosition(0,0)
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
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $sampleCpu = {
            param($d)

            $lines = @(Invoke-SQTShell $d "cat /proc/stat" 2>$null)
            if (-not $lines -or $lines.Count -eq 0) { return $null }

            foreach ($line in $lines) {
                if ($line -match '^cpu\s+(.+)$') {
                    $parts = $matches[1] -split '\s+' | Where-Object { $_ -ne '' }
                    if ($parts.Count -ge 4) {
                        $user = [long]$parts[0]
                        $nice = if ($parts.Count -ge 2) { [long]$parts[1] } else { 0 }
                        $system = if ($parts.Count -ge 3) { [long]$parts[2] } else { 0 }
                        $idle = [long]$parts[3]
                        $iowait = if ($parts.Count -ge 5) { [long]$parts[4] } else { 0 }
                        $irq = if ($parts.Count -ge 6) { [long]$parts[5] } else { 0 }
                        $softirq = if ($parts.Count -ge 7) { [long]$parts[6] } else { 0 }
                        $steal = if ($parts.Count -ge 8) { [long]$parts[7] } else { 0 }

                        $idleAll = $idle + $iowait
                        $nonIdle = $user + $nice + $system + $irq + $softirq + $steal
                        $total = $idleAll + $nonIdle

                        return [PSCustomObject]@{ Total = $total; Idle = $idleAll }
                    }
                }
            }

            return $null
        }

        $s1 = & $sampleCpu $dev
        if (-not $s1) { return $null }

        Start-Sleep -Milliseconds 800

        $s2 = & $sampleCpu $dev
        if (-not $s2) { return $null }

        $deltaTotal = $s2.Total - $s1.Total
        $deltaIdle = $s2.Idle - $s1.Idle

        if ($deltaTotal -le 0) {
            try {
                $topLines = @(Invoke-SQTShell $dev "top -n 1" 2>$null)
                foreach ($line in $topLines) {
                    if ($line -match 'User\s+(\d+)%.*System\s+(\d+)%') {
                        $userPct = [int]$matches[1]
                        $systemPct = [int]$matches[2]
                        return [math]::Round(($userPct + $systemPct), 1)
                    }
                }
            }
            catch {
                return $null
            }

            return 0
        }

        $usage = (1 - ($deltaIdle / $deltaTotal)) * 100
        return [math]::Round($usage,1)
    }
    catch {
        return $null
    }
}

# Implement Get-SQTMemoryUsage - reads /proc/meminfo and returns used memory in MB
function Get-SQTMemoryUsage {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $lines = @(Invoke-SQTShell $dev "cat /proc/meminfo" 2>$null)
        if (-not $lines -or $lines.Count -eq 0) { return $null }

        $totalKb = 0
        $availKb = 0
        $freeKb = 0

        foreach ($l in $lines) {
            $line = [string]$l
            if ($line -match 'MemTotal:\s*(\d+)') { $totalKb = [int]$matches[1] }
            elseif ($line -match 'MemAvailable:\s*(\d+)') { $availKb = [int]$matches[1] }
            elseif ($line -match 'MemFree:\s*(\d+)') { $freeKb = [int]$matches[1] }
        }

        if ($availKb -le 0 -and $freeKb -gt 0) { $availKb = $freeKb }
        if ($totalKb -le 0) { return $null }

        $usedKb = $totalKb - $availKb
        $usedMb = [math]::Round(($usedKb / 1024),1)

        return $usedMb
    }
    catch {
        return $null
    }
}

# ------------------------------------------------------------
# Get-SQTDeviceMetrics
# - Reads CPU, memory and load from the connected device.
# - Returns PSCustomObject: CPU (percent), MemoryMB (used), LoadAvg (1m)
# ------------------------------------------------------------
function Get-SQTDeviceMetrics {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $cpuUsage = Get-SQTCPUUsage -Device $dev
        $usedMb = Get-SQTMemoryUsage -Device $dev

        $loadAvg = $null
        try {
            $loadLines = @(Invoke-SQTShell $dev "cat /proc/loadavg" 2>$null)
            if ($loadLines -and $loadLines.Count -gt 0) {
                $fields = ($loadLines[0] -split '\s+' | Where-Object { $_ -ne '' })
                if ($fields.Count -ge 1) { $loadAvg = $fields[0] }
            }
        }
        catch {
            $loadAvg = $null
        }

        return [PSCustomObject]@{
            CPU = $cpuUsage
            MemoryMB = $usedMb
            LoadAvg = $loadAvg
        }
    }
    catch {
        return $null
    }
}

function Get-SQTThreadCount {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $topLines = @(Invoke-SQTShell $dev "top -n 1 2>/dev/null")
        foreach ($line in $topLines) {
            if ($line -match 'Threads?[:\s]+(\d+)') {
                return [int]$matches[1]
            }
        }

        $psLines = @(Invoke-SQTShell $dev "ps 2>/dev/null")
        if ($psLines.Count -gt 1) {
            return ($psLines.Count - 1)
        }
    }
    catch {
        return $null
    }

    return $null
}

function Get-SQTLoadAverage {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $loadLines = @(Invoke-SQTShell $dev "cat /proc/loadavg 2>/dev/null")
        if ($loadLines.Count -gt 0) {
            $fields = ($loadLines[0] -split '\s+' | Where-Object { $_ -ne '' })
            if ($fields.Count -ge 1) {
                return $fields[0]
            }
        }
    }
    catch {
        return $null
    }

    return $null
}

function Get-SQTBatteryInfo {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $batteryLines = @(Invoke-SQTShell $dev "dumpsys battery 2>/dev/null")
        $level = $null
        foreach ($line in $batteryLines) {
            if ($line -match 'level:\s*(\d+)') {
                $level = [int]$matches[1]
                break
            }
        }

        if ($level -ne $null) {
            return "$level%"
        }
    }
    catch {
        return $null
    }

    return $null
}

function Get-SQTTemperature {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $batteryLines = @(Invoke-SQTShell $dev "dumpsys battery 2>/dev/null")
        foreach ($line in $batteryLines) {
            if ($line -match 'temperature\s*[:=]\s*(-?\d+(?:\.\d+)?)') {
                $raw = $matches[1]
                if (-not [string]::IsNullOrWhiteSpace($raw)) {
                    $value = [double]$raw
                    if ($value -gt 100) {
                        $value = [math]::Round($value / 10, 1)
                    }
                    return "$value°C"
                }
            }
        }
    }
    catch {
        return $null
    }

    return $null
}

function Get-SQTStorageInfo {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $dfLines = @(Invoke-SQTShell $dev "df /data 2>/dev/null || df 2>/dev/null")
        foreach ($line in $dfLines) {
            if ($line -match '(\d+)%\s+.*(?:/data|/storage|/mnt|/sdcard|/system|/cache)') {
                return "$($matches[1])%"
            }
            elseif ($line -match '(\d+)%') {
                return "$($matches[1])%"
            }
        }
    }
    catch {
        return $null
    }

    return $null
}

function Get-SQTWifiInfo {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $wifiLines = @(Invoke-SQTShell $dev "dumpsys wifi 2>/dev/null")
        foreach ($line in $wifiLines) {
            if ($line -match '(?:RSSI|mRssi|rssi|signal)\s*[:=]?\s*(-?\d+)') {
                $raw = $matches[1]
                if (-not [string]::IsNullOrWhiteSpace($raw)) {
                    return "$raw dBm"
                }
            }
        }
    }
    catch {
        return $null
    }

    return $null
}

function Get-SQTDeviceIP {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $propIp = @(Invoke-SQTShell $dev "getprop dhcp.wlan0.ipaddress 2>/dev/null") | Select-Object -First 1
        if (-not [string]::IsNullOrWhiteSpace($propIp) -and $propIp -ne '0.0.0.0') {
            return $propIp.Trim()
        }

        $ipLines = @(Invoke-SQTShell $dev "ip -f inet addr show wlan0 2>/dev/null | grep 'inet ' 2>/dev/null")
        foreach ($line in $ipLines) {
            if ($line -match 'inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)') {
                return $matches[1]
            }
        }

        $ifconfigLines = @(Invoke-SQTShell $dev "ifconfig wlan0 2>/dev/null")
        foreach ($line in $ifconfigLines) {
            if ($line -match 'inet\s+addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)') {
                return $matches[1]
            }
            if ($line -match 'inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)') {
                return $matches[1]
            }
        }
    }
    catch {
        return $null
    }

    return $null
}

function Get-SQTInternetStatus {
    param(
        [Parameter(Mandatory=$true)][string]$Device
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $pingLines = @(Invoke-SQTShell $dev "ping -c 1 -W 1 8.8.8.8 2>/dev/null")
        foreach ($line in $pingLines) {
            if ($line -match '(\d+) packets transmitted,\s*(\d+) (?:packets )?received') {
                $sent = [int]$matches[1]
                $recv = [int]$matches[2]
                if ($sent -gt 0 -and $recv -ge 1) {
                    return 'Online'
                }
                return 'Offline'
            }
            if ($line -match '0% packet loss') {
                return 'Online'
            }
        }
    }
    catch {
        return $null
    }

    return 'Offline'
}

function Get-SQTLastErrors {
    param(
        [Parameter(Mandatory=$true)][string]$Device,
        [int]$Lines = 50
    )

    if ($Device -match ':') { $dev = $Device.Split(':')[0] } else { $dev = $Device }

    try {
        $logLines = @(Invoke-SQTShell $dev "logcat -d -t $Lines 2>/dev/null")
        if (-not $logLines) {
            return [PSCustomObject]@{
                ErrorCount = 0
                WarningCount = 0
                LastError = '-'
            }
        }

        $errorLines = $logLines | Where-Object { $_ -match '\bE/' }
        $warningLines = $logLines | Where-Object { $_ -match '\bW/' }
        $lastErrorLine = $errorLines | Select-Object -Last 1

        return [PSCustomObject]@{
            ErrorCount = $errorLines.Count
            WarningCount = $warningLines.Count
            LastError = if ($lastErrorLine) { $lastErrorLine.Trim() } else { '-' }
        }
    }
    catch {
        return [PSCustomObject]@{
            ErrorCount = 0
            WarningCount = 0
            LastError = '-'
        }
    }
}

# End of file
