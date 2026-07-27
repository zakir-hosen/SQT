function Start-SQTScreenRecording {

    $config = Get-SQTConfig

    if ([string]::IsNullOrWhiteSpace($config.CurrentDevice)) {
        Write-SQTLog "No device selected." "ERROR"
        Pause-SQT
        return
    }

    $device = $config.CurrentDevice
    if ($device -match ':') { $device = $device.Split(':')[0] }

    # Decide remote and local paths
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $remoteFile = "/sdcard/sqt_record_$timestamp.mp4"

    # Prefer active session video folder if session exists
    $session = Get-SQTSession
    if ($session) {
        $localFolder = Get-SQTVideoFolder
    }
    else {
        $localFolder = Join-Path $PSScriptRoot "..\..\$($config.TempFolder)"
    }

    if (-not (Test-Path $localFolder)) {
        New-Item -ItemType Directory -Path $localFolder -Force | Out-Null
    }

    $localFile = Join-Path $localFolder "sqt_record_$timestamp.mp4"

    Write-SQTLog "Ready to start screen recording on device $device."
    Read-Host "Press ENTER to start recording"

    try {
        Start-SQTADBServer

        if ([string]::IsNullOrWhiteSpace($remoteFile)) {
            throw "Remote file path is empty."
        }

        if ([string]::IsNullOrWhiteSpace($localFile)) {
            throw "Local file path is empty."
        }

        # Ask user for duration; empty means manual stop (less reliable on some hosts)
        $durationInput = Read-Host "Enter duration in seconds (leave empty for manual stop)"
        $duration = $null
        if (-not [string]::IsNullOrWhiteSpace($durationInput)) {
            if (-not [int]::TryParse($durationInput, [ref]$duration)) {
                Write-SQTLog "Invalid duration value." "ERROR"
                return
            }
        }

        if ($duration) {
            Write-SQTLog "Starting timed screenrecord for $duration seconds..."
            $args = @(
                "-s",
                "$device`:5555",
                "shell",
                "screenrecord",
                "--time-limit",
                "$duration",
                "$remoteFile"
            )

            Write-SQTLog "Running: Get-SQTADB @($($args -join ' '))" "INFO"

            # This will block until the recording finishes
            Invoke-SQTADB -Arguments $args | Out-Null

            Write-SQTLog "Recording finished. Pulling file..."

            try {
                Pull-SQTFile -Device $device -Remote $remoteFile -Local $localFile
                Write-SQTLog "Recording saved to: $localFile" "SUCCESS"
            }
            catch {
                Write-SQTLog "Failed to pull recorded file: $($_.Exception.Message)" "ERROR"
                Write-SQTLog ($_.Exception | Out-String) "ERROR"
                throw
            }

            # Cleanup remote file
            try {
                Invoke-SQTADB @(
                    "-s",
                    "$device`:5555",
                    "shell",
                    "rm",
                    $remoteFile
                ) | Out-Null
            }
            catch {
                Write-SQTLog "Warning: failed to remove remote file: $($_.Exception.Message)" "WARNING"
            }
        }
        else {
            Write-SQTLog "Starting manual screenrecord. Press ENTER to stop." "INFO"

            # Fallback to previous Start-Process approach for manual stop
            $adb = Get-SQTADB
            if ([string]::IsNullOrWhiteSpace($adb) -or -not (Test-Path $adb)) {
                throw "ADB executable unavailable for manual recording. Use timed recording instead."
            }

            $argList = @(
                "-s",
                "$device`:5555",
                "shell",
                "screenrecord",
                "$remoteFile"
            )

            Write-SQTLog "Running: $adb $($argList -join ' ')" "INFO"

            $process = Start-Process -FilePath $adb -ArgumentList $argList -PassThru
            Write-SQTLog "Process Id: $($process.Id)" "INFO"

            Read-Host "Press ENTER to stop"

            if ($process -and -not $process.HasExited) {
                try { $process.Kill() } catch { Write-SQTLog "Failed to kill process: $($_.Exception.Message)" "WARNING" }
                Start-Sleep -Milliseconds 500
            }

            Write-SQTLog "Stopping recording and pulling file..."

            try {
                Pull-SQTFile -Device $device -Remote $remoteFile -Local $localFile
                Write-SQTLog "Recording saved to: $localFile" "SUCCESS"
            }
            catch {
                Write-SQTLog "Failed to pull recorded file: $($_.Exception.Message)" "ERROR"
                Write-SQTLog ($_.Exception | Out-String) "ERROR"
                throw
            }

            try {
                Invoke-SQTADB @(
                    "-s",
                    "$device`:5555",
                    "shell",
                    "rm",
                    $remoteFile
                ) | Out-Null
            }
            catch {
                Write-SQTLog "Warning: failed to remove remote file: $($_.Exception.Message)" "WARNING"
            }
        }

    }
    catch {
        Write-SQTLog "Screen recording failed: $($_.Exception.Message)" "ERROR"
        Write-SQTLog ($_.Exception | Out-String) "ERROR"
    }

    Pause-SQT

}