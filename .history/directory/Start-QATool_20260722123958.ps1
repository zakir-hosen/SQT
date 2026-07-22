# Load Common Files
. "$PSScriptRoot\..\common\menu.ps1"
. "$PSScriptRoot\..\common\logger.ps1"

do {

    Show-MainMenu

    $choice = Read-Host "Select"

    switch ($choice) {

        "1" {
            Write-QALog "Connect Device (Coming Soon)"
            Pause
        }

        "2" {
            Write-QALog "Device Information (Coming Soon)"
            Pause
        }

        "3" {
            Write-QALog "Logcat (Coming Soon)"
            Pause
        }

        "0" {
            break
        }

        default {
            Write-Host "Invalid option." -ForegroundColor Red
            Pause
        }
    }

} while ($true)