if (-not [string]::IsNullOrWhiteSpace($config.CurrentDevice)) {
    $appPid = Get-SQTAppProcessId -Device $config.CurrentDevice -Package $config.PackageName
}
else {
    Write-SQTLog "No device selected." "ERROR"
    Pause-SQT
    return
}

Clear-SQTLogcat -Device $config.CurrentDevice

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

Read-Host "Logging... Press ENTER to stop"

$process.Kill()