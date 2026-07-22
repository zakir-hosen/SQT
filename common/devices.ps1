# ============================================================
# Sicunet QA Toolkit
# Device Storage
# ============================================================

function Show-SQTDevices {

    Clear-Host

    $devices = @(Get-SQTDevices)

    Write-Host ""
    Write-Host "Saved Devices"
    Write-Host "-------------"

    if ($devices.Count -eq 0) {

        Write-Host "No devices found."

    }
    else {

        $i = 1

        foreach ($device in $devices) {

            Write-Host "$i. $($device.Name) - $($device.IP)"

            $i++

        }

    }

    Pause-SQT

}
function Get-SQTDevices {

    $path = Join-Path $PSScriptRoot "devices.json"

    if (!(Test-Path $path)) {

        @() | ConvertTo-Json | Set-Content $path

    }

    $json = Get-Content $path -Raw

    if ([string]::IsNullOrWhiteSpace($json)) {

        return @()

    }

    return $json | ConvertFrom-Json

}

function Save-SQTDevices {

    param($Devices)

    $path = Join-Path $PSScriptRoot "devices.json"

    $Devices |
    ConvertTo-Json -Depth 5 |
    Set-Content $path

}

function Connect-NewSQTDevice {

    Clear-Host

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "        CONNECT TO DEVICE"
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    $ip = Read-Host "Enter Device IP"

    if ([string]::IsNullOrWhiteSpace($ip)) {

        Write-SQTLog "No IP entered." "ERROR"
        Pause-SQT
        return

    }

    Write-SQTLog "Connecting to $ip..."

    $result = Connect-SQTADB $ip

    Write-Host ""
    Write-Host $result

    if ($result -match "connected") {

        Set-SQTCurrentDevice -Name $ip -IP $ip

        Write-SQTLog "Connected successfully." "SUCCESS"

    }
    else {

        Write-SQTLog "Connection failed." "ERROR"

    }

    Pause-SQT

}