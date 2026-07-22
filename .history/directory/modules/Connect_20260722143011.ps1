# ============================================================
# Device Manager
# ============================================================

function Connect-SQTDevice {

    do {

        Clear-Host

        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "          DEVICE MANAGER"
        Write-Host "==========================================" -ForegroundColor Cyan

        Write-Host ""
        Write-Host "1. Connect to New Device"
        Write-Host "2. Select Saved Device"
        Write-Host "3. Add Device"
        Write-Host "4. Remove Device"
        Write-Host "5. Test Connection"
        Write-Host ""
        Write-Host "0. Back"
        Write-Host ""

        $choice = Read-Host "Select"

        switch ($choice) {

            "1" {

                Write-SQTLog "Connect Device - Coming Soon"

                Pause-SQT

            }

            "2" {

                Write-SQTLog "Select Device - Coming Soon"

                Pause-SQT

            }

            "3" {

                Write-SQTLog "Add Device - Coming Soon"

                Pause-SQT

            }

            "4" {

                Write-SQTLog "Remove Device - Coming Soon"

                Pause-SQT

            }

            "5" {

    Invoke-SQTADB "version"

    Pause-SQT

}

            "0" {

                return

            }

            default {

                Write-SQTLog "Invalid Selection" "ERROR"

                Pause-SQT

            }

        }

    } while ($true)

}