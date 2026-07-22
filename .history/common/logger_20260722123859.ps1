function Write-QALog {

    param(
        [string]$Message
    )

    $time = Get-Date -Format "HH:mm:ss"

    Write-Host "[$time] $Message" -ForegroundColor Green

}