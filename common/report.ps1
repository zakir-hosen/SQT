# ============================================================
# Report Manager
# ============================================================

function New-SQTSession {

    # 1. Determine device folder name (fallback to "UnknownDevice" if not set)
    $deviceName = "UnknownDevice"
    if ($global:config -and $global:config.CurrentDevice) {
        $deviceName = $global:config.CurrentDevice
    }
    elseif ($config -and $config.CurrentDevice) {
        $deviceName = $config.CurrentDevice
    }

    # Clean the device name to remove characters invalid in Windows folder paths (e.g. colons in IP:Port ADB addresses)
    $safeDeviceName = $deviceName -replace '[:\\/*?"<>|]', '_'

    # 2. Path: SQT\reports\<DeviceName>\<Date>\<Time>
    $base = Join-Path $PSScriptRoot "..\reports"
    $deviceFolder = Join-Path $base $safeDeviceName

    $date = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "HH-mm-ss"

    $dateFolder = Join-Path $deviceFolder $date
    $session = Join-Path $dateFolder $time

    # 3. Create the session directory tree
    if (!(Test-Path $session)) {
        New-Item $session -ItemType Directory -Force | Out-Null
    }

    return $session
}