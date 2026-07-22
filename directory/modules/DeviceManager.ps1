# ============================================================
# Device Manager
# ============================================================

function Add-SQTDevice {

    $devices = @(Get-SQTDevices)

    Clear-Host

    Write-Host ""
    Write-Host "Add New Device"
    Write-Host "--------------"

    $name = Read-Host "Device Name"

    $ip = Read-Host "Device IP"

    $devices += [PSCustomObject]@{

        Name = $name
        IP   = $ip

    }

    Save-SQTDevices $devices

    Write-SQTLog "Device saved successfully." "SUCCESS"

    Pause-SQT

}
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

                Connect-NewSQTDevice

                Pause-SQT

            }

            "2" {

                Show-SQTDevices

                Pause-SQT

            }

            "3" {

                Add-SQTDevice

                Pause-SQT

            }

            "4" {

                Write-SQTLog "Remove Device - Coming Soon"

                Pause-SQT

            }

            "5" {

                Write-SQTLog "Test Connection - Coming Soon"

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