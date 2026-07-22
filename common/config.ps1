# ==========================================
# Configuration Manager
# ==========================================

$Script:Config = $null

function Get-SQTConfig {

    if ($null -eq $Script:Config) {

        $configPath = Join-Path $PSScriptRoot "config.json"

        $Script:Config = Get-Content $configPath -Raw | ConvertFrom-Json

    }

    return $Script:Config

}

function Save-SQTConfig {

    $configPath = Join-Path $PSScriptRoot "config.json"

    $Script:Config | ConvertTo-Json -Depth 5 | Set-Content $configPath

}
function Set-SQTCurrentDevice {

    param(

        [string]$Name,

        [string]$IP

    )

    $config = Get-SQTConfig

    $config.CurrentDevice = $IP
    $config.CurrentDeviceName = $Name

    Save-SQTConfig

}