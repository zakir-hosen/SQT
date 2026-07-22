function Add-SQTDevice {

    $devices = Get-SQTDevices

    $name = Read-Host "Device Name"

    $ip = Read-Host "Device IP"

    $devices += [PSCustomObject]@{

        Name = $name
        IP   = $ip

    }

    Save-Devices $devices

    Write-QALog "Device Saved." "SUCCESS"

}