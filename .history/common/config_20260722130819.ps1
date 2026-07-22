# ==========================================
# Configuration Manager
# ==========================================

$Script:Config = $null

function Get-Config {

    if ($null -eq $Script:Config) {

        $configPath = Join-Path $PSScriptRoot "config.json"

        $Script:Config = Get-Content $configPath -Raw | ConvertFrom-Json

    }

    return $Script:Config

}

function Save-QAConfig {

    $configPath = Join-Path $PSScriptRoot "config.json"

    $Script:Config | ConvertTo-Json -Depth 5 | Set-Content $configPath

}