function Write-QALog {

    param(
        [string]$Message,
        [string]$Type = "INFO"
    )

    $time = Get-Date -Format "HH:mm:ss"

    switch ($Type) {

        "INFO" {
            $color = "White"
        }

        "SUCCESS" {
            $color = "Green"
        }

        "WARNING" {
            $color = "Yellow"
        }

        "ERROR" {
            $color = "Red"
        }

        default {
            $color = "Gray"
        }

    }

    Write-Host "[$time][$Type] $Message" -ForegroundColor $color
}