# ==========================================
# Load Common Files
# ==========================================

. "$PSScriptRoot\..\common\config.ps1"
. "$PSScriptRoot\..\common\devices.ps1"
. "$PSScriptRoot\..\common\adb.ps1"
. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\common\utils.ps1"
. "$PSScriptRoot\..\common\menu.ps1"

$config = Get-SQTConfig

$currentDevice = $config.CurrentDevice

if ([string]::IsNullOrWhiteSpace($currentDevice)) {
    $currentDevice = "Not Connected"
}

do {

    Show-MainMenu $currentDevice

    $choice = Read-Host "Select Option"

    switch ($choice) {

        "1" {
            Connect-SQTDevice
        }

        "2" {

            Write-SQTLog "Device Information module is under development."

            Pause-SQT

        }

        "3" {

            Write-SQTLog "Capture Logcat module is under development."

            Pause-SQT

        }

        "4" {

            Write-SQTLog "Screenshot module is under development."

            Pause-SQT

        }

        "5" {

            Write-SQTLog "Screen Recording module is under development."

            Pause-SQT

        }

        "6" {

            Write-SQTLog "Collect Evidence module is under development."

            Pause-SQT

        }

        "7" {

            Write-SQTLog "Bug Report module is under development."

            Pause-SQT

        }

        "8" {

            Write-SQTLog "Settings module is under development."

            Pause-SQT

        }

        "0" {

            Write-SQTLog "Goodbye!" "SUCCESS"

            break

        }

        default {

            Write-SQTLog "Invalid menu option." "ERROR"

            Pause-SQT

        }

    }

} while ($true)