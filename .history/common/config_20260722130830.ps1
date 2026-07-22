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

function Save-SConfig {

    $configPath = Join-Path $PSScriptRoot "config.json"

    $Script:Config | ConvertTo-Json -Depth 5 | Set-Content $configPath

}