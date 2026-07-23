function Show-MainMenu {

    Clear-Host

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                 SICUNET QA TOOLKIT v1.0.0" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    $config = Get-SQTConfig

    Write-Host "Current Device : " -NoNewline

    if ([string]::IsNullOrWhiteSpace($config.CurrentDeviceName)) {

        Write-Host "Not Connected" -ForegroundColor Yellow

    }
    else {

        Write-Host "$($config.CurrentDeviceName) ($($config.CurrentDevice))" -ForegroundColor Green

    }

    Write-Host ""

    Write-Host "DEVICE" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------"
    Write-Host " 1. Device Manager"
    Write-Host " 2. Device Information"

    Write-Host ""

    Write-Host "LOGS" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------"
    Write-Host " 3. Capture Logcat"
    Write-Host " 4. Live Log Viewer"
    Write-Host " 5. Screenshot"
    Write-Host " 6. Screen Recording"

    Write-Host ""

    Write-Host "REPORTS" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------"
    Write-Host " 7. Performance Info"
    Write-Host " 8. Collect Evidence"
    Write-Host " 9. Bug Report"

    Write-Host ""

    Write-Host "SETTINGS" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------"
    Write-Host " 10. Settings"

    Write-Host ""
    Write-Host " 0. Exit"

    Write-Host ""
}