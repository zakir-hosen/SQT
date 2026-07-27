function Start-SQTLiveLogViewer {

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

    $appPid = $null
    if (-not [string]::IsNullOrWhiteSpace($package)) {
        $appPid = Get-SQTAppProcessId -Device $config.CurrentDevice -Package $package
    }

    if (-not [string]::IsNullOrWhiteSpace($package) -and [string]::IsNullOrWhiteSpace($appPid)) {
        Write-SQTLog "Application is not running. Start the app and try again." "ERROR"
        Pause-SQT
        return
    }

    $logDir = Join-Path $PSScriptRoot "..\..\Logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $liveLogFile = Join-Path $logDir "LiveLogViewer.log"
    Set-Content -Path $liveLogFile -Value @()

    $adbArgs = @(
        "-s",
        "$($config.CurrentDevice):5555",
        "logcat",
        "-d",
        "-t",
        "200",
        "-v",
        "time"
    )

    if (-not [string]::IsNullOrWhiteSpace($appPid)) {
        $adbArgs += "--pid=$appPid"
    }

    $seenLines = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $lineCount = 0

    Write-SQTLog "Streaming logcat output. Press ENTER to stop."

    while ($true) {
        try {
            $output = @(Invoke-SQTADB -Arguments $adbArgs)

            foreach ($line in $output) {
                if ($null -eq $line) {
                    continue
                }

                if ($seenLines.Add($line)) {
                    $lineCount++
                    Add-Content -Path $liveLogFile -Value $line
                    Write-Host $line
                }
            }

            if ([System.Console]::KeyAvailable) {
                $key = [System.Console]::ReadKey($true)
                if ($key.Key -eq [System.ConsoleKey]::Enter) {
                    break
                }
            }

            Start-Sleep -Seconds 1
        }
        catch {
            Write-SQTLog "Live log viewer stopped: $($_.Exception.Message)" "ERROR"
            break
        }
    }

    Write-SQTLog "Live log viewer stopped." "SUCCESS"
}
