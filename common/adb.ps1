# ============================================================
# Sicunet QA Toolkit
# ADB Service
# Version: 1.0.0
# ============================================================

# ------------------------------------------------------------
# Get ADB executable
# ------------------------------------------------------------
function Get-SQTADB {

    $config = Get-SQTConfig

    if ([string]::IsNullOrWhiteSpace($config.ADBPath)) {
        throw "ADB path is not configured."
    }

    if (!(Test-Path $config.ADBPath)) {
        throw "ADB not found:`n$($config.ADBPath)"
    }

    return $config.ADBPath
}

# ------------------------------------------------------------
# Execute any ADB command
# ------------------------------------------------------------
function Invoke-SQTADB {

    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $adb = Get-SQTADB

    & $adb @Arguments
}

# ------------------------------------------------------------
# Start ADB Server
# ------------------------------------------------------------
function Start-SQTADBServer {

    Invoke-SQTADB @("start-server") | Out-Null
}

# ------------------------------------------------------------
# Stop ADB Server
# ------------------------------------------------------------
function Stop-SQTADBServer {

    Invoke-SQTADB @("kill-server") | Out-Null
}

# ------------------------------------------------------------
# Connect WiFi Device
# ------------------------------------------------------------
function Connect-SQTADB {

    param(
        [Parameter(Mandatory)]
        [string]$IP
    )

    Start-SQTADBServer

    return Invoke-SQTADB @("connect", "$IP`:5555")
}

# ------------------------------------------------------------
# Disconnect Device
# ------------------------------------------------------------
function Disconnect-SQTADB {

    param(
        [Parameter(Mandatory)]
        [string]$IP
    )

    return Invoke-SQTADB @("disconnect", "$IP`:5555")
}

# ------------------------------------------------------------
# Connected Devices
# ------------------------------------------------------------
function Get-SQTConnectedDevices {

    $output = Invoke-SQTADB @("devices")

    return $output | Select-Object -Skip 1 |
    Where-Object { $_ -match "device$" }
}

# ------------------------------------------------------------
# Execute Shell Command
# ------------------------------------------------------------
function Invoke-SQTShell {

    param(

        [Parameter(Mandatory)]
        [string]$Device,

        [Parameter(Mandatory)]
        [string]$Command

    )

    return Invoke-SQTADB @(
        "-s",
        "$Device`:5555",
        "shell",
        $Command
    )

}

# ------------------------------------------------------------
# Get Android PID
# ------------------------------------------------------------
function Get-SQTAppProcessId {

    param(

        [Parameter(Mandatory)]
        [string]$Device,

        [Parameter(Mandatory)]
        [string]$Package

    )

    $appPid = Invoke-SQTShell $Device "pidof -s $Package"

    return ($appPid | Out-String).Trim()
}

# ------------------------------------------------------------
# Screenshot
# ------------------------------------------------------------
function Take-SQTScreenshot {

    param(

        [string]$Device,

        [string]$Remote = "/sdcard/sqt_screen.png"

    )

    Invoke-SQTADB @(
        "-s",
        "$Device`:5555",
        "shell",
        "screencap",
        "-p",
        $Remote
    )

}

# ------------------------------------------------------------
# Screen Recording
# ------------------------------------------------------------
function Start-SQTScreenRecord {

    param(

        [string]$Device,

        [string]$Remote = "/sdcard/sqt_record.mp4"

    )

    Invoke-SQTADB @(
        "-s",
        "$Device`:5555",
        "shell",
        "screenrecord",
        $Remote
    )

}

# ------------------------------------------------------------
# Pull File
# ------------------------------------------------------------
function Pull-SQTFile {

    param(

        [string]$Device,

        [string]$Remote,

        [string]$Local

    )

    Invoke-SQTADB @(
        "-s",
        "$Device`:5555",
        "pull",
        $Remote,
        $Local
    )

}

# ------------------------------------------------------------
# Logcat
# ------------------------------------------------------------
function Start-SQTLogcatCapture {

    param(

        [string]$Device,

        [string]$Package,

        [string]$Output

    )

    $appPid = Get-SQTAppProcessId $Device $Package

    if ([string]::IsNullOrWhiteSpace($appPid)) {

        throw "Application is not running."

    }

    Invoke-SQTADB @(
        "-s",
        "$Device`:5555",
        "logcat",
        "--pid=$appPid"
    ) | Tee-Object -FilePath $Output

}

# ------------------------------------------------------------
# Device Model
# ------------------------------------------------------------
function Get-SQTModel {

    param([string]$Device)

    Invoke-SQTShell $Device "getprop ro.product.model"

}

# ------------------------------------------------------------
# Android Version
# ------------------------------------------------------------
function Get-SQTAndroidVersion {

    param([string]$Device)

    Invoke-SQTShell $Device "getprop ro.build.version.release"

}

# ------------------------------------------------------------
# Device Serial
# ------------------------------------------------------------
function Get-SQTSerial {

    param([string]$Device)

    Invoke-SQTADB @(
        "-s",
        "$Device`:5555",
        "get-serialno"
    )

}

function Clear-SQTLogcat {

    param(
        [string]$Device
    )

    Invoke-SQTADB @(
        "-s",
        "$Device`:5555",
        "logcat",
        "-c"
    )

}

function Test-SQTPackageRunning {

    param(

        [string]$Device,

        [string]$Package

    )

    $appPid = Get-SQTAppProcessId -Device $Device -Package $Package

    return -not [string]::IsNullOrWhiteSpace($appPid)

}