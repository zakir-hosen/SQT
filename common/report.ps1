# ============================================================
# Report Manager
# ============================================================

function New-SQTSession {

    $base = Join-Path $PSScriptRoot "..\directory\Reports"

    $date = Get-Date -Format "yyyy-MM-dd"

    $time = Get-Date -Format "HH-mm-ss"

    $folder = Join-Path $base $date

    if (!(Test-Path $folder)) {

        New-Item $folder -ItemType Directory | Out-Null

    }

    $session = Join-Path $folder $time

    New-Item $session -ItemType Directory | Out-Null

    return $session

}