# ============================================================
# ADB Helper
# ============================================================

function Invoke-SQTADB {

    param(

        [string]$Arguments

    )

    $config = Get-SQTConfig

    $adb = $config.ADBPath

    if (!(Test-Path $adb)) {

        throw "ADB not found."

    }

    & $adb $Arguments

}