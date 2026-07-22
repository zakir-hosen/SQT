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

            Pause-QA

        }

        "2" {

            Write-QALog "Device Information module is under development."

            Pause-QA

        }

        "3" {

            Write-QALog "Capture Logcat module is under development."

            Pause-QA

        }

        "4" {

            Write-SQTLog "Screenshot module is under development."

            Pause-QA

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