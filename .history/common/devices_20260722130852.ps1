function Get-SQTDevices {

    $path = Join-Path $PSScriptRoot "devices.json"

    return Get-Content $path -Raw | ConvertFrom-Json

}

function Save-SQTDevices($devices) {

    $path = Join-Path $PSScriptRoot "devices.json"

    $devices | ConvertTo-Json -Depth 5 | Set-Content $path

}