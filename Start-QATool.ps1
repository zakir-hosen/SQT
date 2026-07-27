# ============================================================
# Sicunet QA Toolkit
# File    : Start-QATool.ps1
# Version : 0.1.0
# Author  : Zakir Hosen
# ============================================================

# # ============================================================
# # Bootstrap
# # ============================================================

# . "$PSScriptRoot\common\logger.ps1"
# . "$PSScriptRoot\common\utils.ps1"

# # Load remaining common files
# Import-SQTModules "$PSScriptRoot\common"

# # Load feature modules
# Import-SQTModules "$PSScriptRoot\modules"
# Common
. "$PSScriptRoot\common\logger.ps1"
. "$PSScriptRoot\common\utils.ps1"
. "$PSScriptRoot\common\config.ps1"
. "$PSScriptRoot\common\devices.ps1"
. "$PSScriptRoot\common\adb.ps1"
. "$PSScriptRoot\common\menu.ps1"
. "$PSScriptRoot\common\report.ps1"

# Modules
. "$PSScriptRoot\modules\Core\Session.ps1"

. "$PSScriptRoot\modules\Device\DeviceManager.ps1"
. "$PSScriptRoot\modules\Device\DeviceInfo.ps1"

. "$PSScriptRoot\modules\Capture\Logcat.ps1"
. "$PSScriptRoot\modules\Capture\Screenshot.ps1"
. "$PSScriptRoot\modules\Capture\ScreenRecord.ps1"

. "$PSScriptRoot\modules\Report\LiveLogViewer.ps1"
. "$PSScriptRoot\modules\Report\Performance.ps1"
. "$PSScriptRoot\modules\Report\CollectEvidence.ps1"
. "$PSScriptRoot\modules\Report\BugReport.ps1"

. "$PSScriptRoot\modules\Settings\Settings.ps1"

# ============================================================
# Main Application
# ============================================================

try {

    do {

        # --------------------------------------------
        # Refresh Current Device
        # --------------------------------------------

        $config = Get-SQTConfig

        $currentDevice = $config.CurrentDevice

        if ([string]::IsNullOrWhiteSpace($currentDevice)) {
            $currentDevice = "Not Connected"
        }

        # --------------------------------------------
        # Display Menu
        # --------------------------------------------

        Show-MainMenu $currentDevice

        $choice = Read-Host "Select Option"

        switch ($choice) {

            # =====================================================
            # Device
            # =====================================================

            "1" {

                Open-SQTDeviceManager

            }

            "2" {

                Show-SQTDeviceInfo

            }

            # =====================================================
            # Logs
            # =====================================================

            "3" {

                Start-SQTLogcat

            }

            "4" {

                Start-SQTLiveLogViewer

            }

            "5" {

                Take-SQTScreenshot

            }

            "6" {

                Start-SQTScreenRecording

            }

            # =====================================================
            # Reports & Monitor
            # =====================================================

            "7" {

                Show-SQTPerformanceInfo

            }

            "8" {

                Start-SQTCollectEvidence

            }

            "9" {

                New-SQTBugReport

            }

            "10" {

                Start-SQTSession

            }


            # =====================================================
            # Settings
            # =====================================================

            "11" {

                Open-SQTSettings

            }

            # =====================================================
            # Exit
            # =====================================================

            "0" {

                Write-SQTLog "Thank you for using Sicunet QA Toolkit." "SUCCESS"

                break

            }

            default {

                Write-SQTLog "Invalid menu option." "ERROR"

                Pause-SQT

            }

        }

    } while ($true)

}
catch {

    Write-SQTLog "Unexpected error: $($_.Exception.Message)" "ERROR"

    Pause-SQT

}