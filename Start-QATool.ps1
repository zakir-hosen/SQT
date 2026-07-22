# ============================================================
# Sicunet QA Toolkit
# File    : Start-QATool.ps1
# Version : 1.0.0
# Author  : Zakir Hosen
# ============================================================

# ============================================================
# Load Common Files
# ============================================================

. "$PSScriptRoot\common\config.ps1"
. "$PSScriptRoot\common\devices.ps1"
. "$PSScriptRoot\common\adb.ps1"
. "$PSScriptRoot\common\logger.ps1"
. "$PSScriptRoot\common\utils.ps1"
. "$PSScriptRoot\common\menu.ps1"

# ============================================================
# Load Directory Modules
# ============================================================

. "$PSScriptRoot\modules\Device\DeviceManager.ps1"
. "$PSScriptRoot\modules\Device\DeviceInfo.ps1"
. "$PSScriptRoot\modules\Capture\Logcat.ps1"
. "$PSScriptRoot\modules\Capture\Screenshot.ps1"
. "$PSScriptRoot\modules\Capture\ScreenRecord.ps1"


# ============================================================
# Report & settings Modules
# ============================================================

. "$PSScriptRoot\modules\Report\BugReport.ps1"
. "$PSScriptRoot\modules\Report\Performance.ps1"
. "$PSScriptRoot\modules\Report\CollectEvidence.ps1"
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

                Start-SQTCollectEvidence

            }

            "8" {

                New-SQTBugReport

            }

            # =====================================================
            # Settings
            # =====================================================

            "9" {

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