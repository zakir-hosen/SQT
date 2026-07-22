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