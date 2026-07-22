# ==========================================
# Load Common Files
# ==========================================

. "$PSScriptRoot\..\common\menu.ps1"
. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\common\utils.ps1"
. "$PSScriptRoot\..\common\config.ps1"

$currentDevice = "Not Connected"

do {

    Show-MainMenu $currentDevice

    $choice = Read-Host "Select Option"

    switch ($choice) {

        "1" {

            Write-QALog "Connect Device module is under development."

            Pause-S

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

            Pause-QA

        }

        "6" {

            Write-SQTLog "Collect Evidence module is under development."

            Pause-QA

        }

        "7" {

            Write-SQTLog "Bug Report module is under development."

            Pause-QA

        }

        "8" {

            Write-SQTLog "Settings module is under development."

            Pause-QA

        }

        "0" {

            Write-SQTLog "Goodbye!" "SUCCESS"

            break

        }

        default {

            Write-SQTLog "Invalid menu option." "ERROR"

            Pause-QA

        }

    }

} while ($true)