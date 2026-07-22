function Add-sqtDevice {

    $devices = Get-QADevices

    $name = Read-Host "Device Name"

    $ip = Read-Host "Device IP"

    $devices += [PSCustomObject]@{

        Name = $name
        IP   = $ip

    }

    Save-QADevices $devices

    Write-QALog "Device Saved." "SUCCESS"

}