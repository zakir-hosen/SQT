# ============================================================
# SQT Session Manager
# Version : v0.1
# ============================================================

$global:SQTSession = $null

function Start-SQTSession {

    param(
        [string]$Device,
        [string]$DeviceName,
        [string]$Package
    )

    if ($global:SQTSession) {
        return $global:SQTSession
    }

    $root = Join-Path $PSScriptRoot "..\..\Reports"

    $dateFolder = Get-Date -Format "yyyy-MM-dd"

    $timeFolder = "Session_" + (Get-Date -Format "HH-mm-ss")

    $sessionPath = Join-Path $root $dateFolder
    $sessionPath = Join-Path $sessionPath $timeFolder

    if (!(Test-Path $sessionPath)) {
        New-Item -ItemType Directory -Force -Path $sessionPath | Out-Null
    }

    $global:SQTSession = [PSCustomObject]@{

        StartTime        = Get-Date

        EndTime          = $null

        Tester           = $env:USERNAME

        Device           = $Device

        DeviceName       = $DeviceName

        Package          = $Package

        SessionPath      = $sessionPath

        LogFile          = Join-Path $sessionPath "Logcat.txt"

        ScreenshotFolder = Join-Path $sessionPath "Screenshots"

        VideoFolder      = Join-Path $sessionPath "Videos"

        EvidenceFolder   = Join-Path $sessionPath "Evidence"

    }

    foreach ($folder in @(
            $global:SQTSession.ScreenshotFolder,
            $global:SQTSession.VideoFolder,
            $global:SQTSession.EvidenceFolder
        )) {

        if (!(Test-Path $folder)) {
            New-Item -ItemType Directory -Force -Path $folder | Out-Null
        }
    }

    Save-SQTSession

    Write-SQTLog "Session Started"
    Write-SQTLog "Session Folder:"
    Write-Host $sessionPath -ForegroundColor Green

    return $global:SQTSession
}

function Get-SQTSession {

    return $global:SQTSession

}

function Save-SQTSession {

    if (!$global:SQTSession) {
        return
    }

    $json = [PSCustomObject]@{

        StartTime   = $global:SQTSession.StartTime

        EndTime     = $global:SQTSession.EndTime

        Tester      = $global:SQTSession.Tester

        Device      = $global:SQTSession.Device

        DeviceName  = $global:SQTSession.DeviceName

        Package     = $global:SQTSession.Package

        SessionPath = $global:SQTSession.SessionPath

    }

    $json |

    ConvertTo-Json -Depth 5 |

    Set-Content (Join-Path $global:SQTSession.SessionPath "Session.json")

}

function Stop-SQTSession {

    if (!$global:SQTSession) {
        return
    }

    $global:SQTSession.EndTime = Get-Date

    Save-SQTSession

    Write-SQTLog "Session Finished"

    $global:SQTSession = $null

}

function Get-SQTSessionPath {

    if (!$global:SQTSession) {
        return $null
    }

    return $global:SQTSession.SessionPath

}

function Get-SQTLogFile {

    if (!$global:SQTSession) {
        return $null
    }

    return $global:SQTSession.LogFile

}

function Get-SQTScreenshotFolder {

    if (!$global:SQTSession) {
        return $null
    }

    return $global:SQTSession.ScreenshotFolder

}

function Get-SQTVideoFolder {

    if (!$global:SQTSession) {
        return $null
    }

    return $global:SQTSession.VideoFolder

}