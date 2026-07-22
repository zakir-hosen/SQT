function Show-MainMenu {

    param(
        [string]$CurrentDevice = "Not Connected"
    )

    Clear-Host

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "               SICUNET QA TOOLKIT" -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Current Device : " -NoNewline
    Write-Host $CurrentDevice -ForegroundColor Green

    Write-Host ""
    Write-Host " Device"
    Write-Host " --------------------------------"

    Write-Host " 1. Connect Device"
    Write-Host " 2. Device Information"

    Write-Host ""
    Write-Host " Logs"
    Write-Host " --------------------------------"

    Write-Host " 3. Capture Logcat"
    Write-Host " 4. Screenshot"
    Write-Host " 5. Screen Recording"

    Write-Host ""
    Write-Host " Reports"
    Write-Host " --------------------------------"

    Write-Host " 6. Collect Evidence"
    Write-Host " 7. Bug Report"

    Write-Host ""
    Write-Host " Settings"
    Write-Host " --------------------------------"

    Write-Host " 8. Settings"

    Write-Host ""
    Write-Host " 0. Exit"

    Write-Host ""
}