function Pause-SQT {

    Write-Host ""
    Read-Host "Press ENTER to continue"

}
# ============================================================
# Import all PowerShell modules from a folder
# ============================================================

function Import-SQTModules {

    param(
        [Parameter(Mandatory)]
        [string]$Folder
    )

    if (!(Test-Path $Folder)) {
        Write-Host "Folder not found: $Folder" -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "Loading modules from: $Folder" -ForegroundColor Yellow

    $files = Get-ChildItem -Path $Folder -Filter "*.ps1" -Recurse |
             Sort-Object FullName

    foreach ($file in $files) {

        Write-Host "Loading: $($file.Name)" -ForegroundColor Cyan

        try {

            . $file.FullName

        }
        catch {

            Write-Host ""
            Write-Host "ERROR loading module:" -ForegroundColor Red
            Write-Host $file.FullName -ForegroundColor Yellow
            Write-Host $_.Exception.Message -ForegroundColor Red
            throw

        }

    }

}