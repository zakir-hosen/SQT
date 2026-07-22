function Invoke-ADB {

    param(
        [string]$Command
    )

    $config = Get-Content "$PSScriptRoot\config.json" | ConvertFrom-Json

    & $config.ADBPath $Command

}