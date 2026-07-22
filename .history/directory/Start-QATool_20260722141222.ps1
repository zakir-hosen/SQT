# ============================================================
# Sicunet QA Toolkit
# File    : Start-QATool.ps1
# Version : 1.0.0
# Author  : Zakir Hosen
# ============================================================

# ============================================================
# Load Common Files
# ============================================================

. "$PSScriptRoot\..\common\config.ps1"
. "$PSScriptRoot\..\common\devices.ps1"
. "$PSScriptRoot\..\common\adb.ps1"
. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\common\utils.ps1"
. "$PSScriptRoot\..\common\menu.ps1"

# ============================================================
# Load Directory Modules
# ============================================================

. "$PSScriptRoot\modules\Connect.ps1"
. "$PSScriptRoot\modules\DeviceInfo.ps1"
. "$PSScriptRoot\modules\Logcat.ps1"
. "$PSScriptRoot\modules\Screenshot.ps1"
. "$PSScriptRoot\modules\ScreenRecord.ps1"
. "$PSScriptRoot\modules\BugReport.ps1"
. "$PSScriptRoot\modules\Performance.ps1"
. "$PSScriptRoot\modules\CollectEvidence.ps1"
. "$PSScriptRoot\modules\Settings.ps1"

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

                Connect-SQTDevice

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

                Take-SQTScreenshot

            }

            "5" {

                Start-SQTScreenRecording

            }

            # =====================================================
            # Reports
            # =====================================================

            "6" {

                Show-SQTPerformanceInfo

            }

            "7" {

                New-SQTBugReport

            }

            ""

            # =====================================================
            # Settings
            # =====================================================

            "8" {

                Show-SQTSettings

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