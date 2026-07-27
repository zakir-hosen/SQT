# ============================================================
# Device Manager
# ============================================================

function Open-SQTDeviceManager {

    do {

        Clear-Host

        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "          DEVICE MANAGER"
        Write-Host "==========================================" -ForegroundColor Cyan

        Write-Host ""
        Write-Host "1. Connect to New Device"
        Write-Host "2. Select Saved Device"
        Write-Host "3. Add Device"
        Write-Host "4. Remove Device"
        Write-Host "5. Test Connection"
        Write-Host "6. Show Connected Devices"
        Write-Host "0. Back"
        Write-Host ""

        $choice = Read-Host "Select"

        switch ($choice) {

            "1" {

                Connect-NewSQTDevice

                Pause-SQT

            }

            "2" {

                Show-SQTDevices

                Pause-SQT

            }

            "3" {

                Add-SQTDevice

                Pause-SQT

            }

            "4" {

                Write-SQTLog "Remove Device - Coming Soon"

                Pause-SQT

            }

            "5" {

                Test-SQTConnection

                Pause-SQT

            }

            "6" {

                Show-SQTConnectedDevices

                Pause-SQT

            }

            "0" {

                return

            }

            default {

                Write-SQTLog "Invalid Selection" "ERROR"

                Pause-SQT

            }

        }

    } while ($true)

}
function Add-SQTDevice {

    $devices = @(Get-SQTDevices)

    Clear-Host

    Write-Host ""
    Write-Host "Add New Device"
    Write-Host "--------------"

    $name = Read-Host "Device Name"

    $ip = Read-Host "Device IP"

    $devices += [PSCustomObject]@{

        Name = $name
        IP   = $ip

    }

    Save-SQTDevices $devices

    Write-SQTLog "Device saved successfully." "SUCCESS"

    Pause-SQT

}

function Connect-NewSQTDevice {

    Clear-Host

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "           CONNECT DEVICE"
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    $ip = Read-Host "Enter Device IP"

    if ([string]::IsNullOrWhiteSpace($ip)) {
        return
    }

    Write-SQTLog "Starting ADB Server..."

    Start-SQTADBServer

    Write-SQTLog "Connecting..."

    $result = Connect-SQTADB $ip

    Write-Host ""

    $result

    if ($result -match "connected") {

        Set-SQTCurrentDevice -Name $ip -IP $ip

        Write-SQTLog "Connected Successfully." "SUCCESS"

    }
    else {

        Write-SQTLog "Connection Failed." "ERROR"

    }

    Pause-SQT

}

function Test-SQTConnection {

    Clear-Host

    $config = Get-SQTConfig

    if ([string]::IsNullOrWhiteSpace($config.CurrentDevice)) {

        Write-SQTLog "No current device selected." "ERROR"

        Pause-SQT

        return

    }

    Write-SQTLog "Testing connection..."

    $devices = Get-SQTConnectedDevices

    $found = $false

    foreach ($device in $devices) {

        if ($device -match $config.CurrentDevice) {

            $found = $true

        }

    }

    if ($found) {

        Write-SQTLog "Device is Connected." "SUCCESS"

    }
    else {

        Write-SQTLog "Device is Offline." "ERROR"

    }

    Pause-SQT

}

function Show-SQTConnectedDevices {

    Clear-Host

    Write-Host ""

    Write-Host "Connected Devices"

    Write-Host "-----------------"

    $devices = Get-SQTConnectedDevices

    if ($devices.Count -eq 0) {

        Write-Host ""

        Write-Host "No Devices Connected."

    }
    else {

        foreach ($device in $devices) {

            Write-Host $device

        }

    }

    Pause-SQT

}