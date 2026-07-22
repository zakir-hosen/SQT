# ==========================================
# Load Common Files
# ==========================================

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

            Write-QALog "Screenshot module is under development."

            Pause-QA

        }

        "5" {

            Write-QALog "Screen Recording module is under development."

            Pause-QA

        }

        "6" {

            Write-QALog "Collect Evidence module is under development."

            Pause-QA

        }

        "7" {

            Write-QALog "Bug Report module is under development."

            Pause-QA

        }

        "8" {

            Write-QALog "Settings module is under development."

            Pause-QA

        }

        "0" {

            Write-QALog "Goodbye!" "SUCCESS"

            break

        }

        default {

            Write-QALog "Invalid menu option." "ERROR"

            Pause-QA

        }

    }

} while ($true)