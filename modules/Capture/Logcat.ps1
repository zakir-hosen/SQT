function Start-SQTLogcat {

    $config = Get-SQTConfig

    if ([string]::IsNullOrWhiteSpace($config.CurrentDevice)) {
        Write-SQTLog "No device selected." "ERROR"
        Pause-SQT
        return
    }

    $package = $null

    if (-not [string]::IsNullOrWhiteSpace($config.Package)) {
        $package = $config.Package
    }
    elseif (-not [string]::IsNullOrWhiteSpace($config.PackageName)) {
        $package = $config.PackageName
    }

    if ([string]::IsNullOrWhiteSpace($package)) {
        Write-SQTLog "No package configured." "ERROR"
        Pause-SQT
        return
    }

    $appPid = Get-SQTAppProcessId -Device $config.CurrentDevice -Package $package

    if ([string]::IsNullOrWhiteSpace($appPid)) {
        Write-SQTLog "Application is not running." "ERROR"
        Pause-SQT
        return
    }

    Clear-SQTLogcat -Device $config.CurrentDevice

    $logDir = Join-Path $PSScriptRoot "..\..\Logs"

    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $logFile = Join-Path $logDir "Logcat.txt"

    Write-SQTLog "Ready to capture logs."
    Read-Host "Press ENTER to start"

    $process = Start-Process `
        -FilePath (Get-SQTADB) `
        -ArgumentList @(
        "-s",
        "$($config.CurrentDevice):5555",
        "logcat",
        "--pid=$appPid"
    ) `
        -RedirectStandardOutput $logFile `
        -PassThru `
        -NoNewWindow

    Write-SQTLog "Logging... Press ENTER to stop"
    Read-Host "Press ENTER to stop"

    if ($process -and -not $process.HasExited) {
        $process.Kill()
    }

    Write-SQTLog "Log capture stopped." "SUCCESS"
}