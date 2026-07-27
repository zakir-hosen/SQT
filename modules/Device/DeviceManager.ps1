# ============================================================
# Device Manager
# ============================================================

function Open-SQTDeviceManager {

    do {

        Clear-Host

        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "          DEVICE MANAGER"
        Write-Host "==========================================" -ForegroundColor Cyan

        Write-Host ""
        Write-Host "1. Connect to New Device"
        Write-Host "2. Select Saved Device"
        Write-Host "3. Add Device"
        Write-Host "4. Remove Device"
        Write-Host "5. Test Connection"
        Write-Host "6. Show Connected Devices"
        Write-Host "7. Disconnect Current Device"
        Write-Host "0. Back"
        Write-Host ""

        $choice = Read-Host "Select"

        switch ($choice) {

            "1" {
                Connect-NewSQTDevice
                Pause-SQT
            }

            "2" {
                Select-SQTDevice
                Pause-SQT
            }

            "3" {
                Add-SQTDevice
                Pause-SQT
            }

            "4" {
                Remove-SQTDevice
                Pause-SQT
            }

            "5" {
                Test-SQTConnection
                Pause-SQT
            }

            "6" {
                Show-SQTConnectedDevices
                Pause-SQT
            }

            "7" {
                Disconnect-SQTDevice
                Pause-SQT
            }

            "0" {
                return
            }

            default {
                Write-SQTLog "Invalid Selection" "ERROR"
                Pause-SQT
            }

        }

    } while ($true)

}

function Get-SQTDeviceList {

    $devices = @(Get-SQTDevices)

    if ($null -eq $devices) {
        return @()
    }

    return @($devices)

}

function Show-SQTDevices {

    Clear-Host

    $devices = Get-SQTDeviceList

    Write-Host ""
    Write-Host "Saved Devices"
    Write-Host "-------------"

    if ($devices.Count -eq 0) {
        Write-Host "No devices found."
    }
    else {
        $i = 1

        foreach ($device in $devices) {
            $label = if ($device.Name) { $device.Name } else { "Unnamed" }
            Write-Host "$i. $label - $($device.IP)"
            $i++
        }
    }

    Pause-SQT

}

function Add-SQTDevice {

    $devices = Get-SQTDeviceList

    Clear-Host

    Write-Host ""
    Write-Host "Add New Device"
    Write-Host "--------------"

    $name = (Read-Host "Device Name").Trim()
    $ip = (Read-Host "Device IP").Trim()

    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($ip)) {
        Write-SQTLog "Device name and IP are required." "ERROR"
        return
    }

    $existing = $devices | Where-Object { $_.IP -eq $ip }

    if ($existing) {
        $existing.Name = $name
    }
    else {
        $devices += [PSCustomObject]@{
            Name = $name
            IP   = $ip
        }
    }

    Save-SQTDevices -Devices $devices

    Write-SQTLog "Device saved successfully." "SUCCESS"

}

function Remove-SQTDevice {

    $devices = Get-SQTDeviceList

    if ($devices.Count -eq 0) {
        Write-SQTLog "No saved devices found." "WARNING"
        return
    }

    Clear-Host

    Write-Host ""
    Write-Host "Remove Device"
    Write-Host "-------------"

    $i = 1
    foreach ($device in $devices) {
        $label = if ($device.Name) { $device.Name } else { "Unnamed" }
        Write-Host "$i. $label - $($device.IP)"
        $i++
    }

    $selection = Read-Host "Select device number"
    $parsedSelection = 0

    if (-not [int]::TryParse($selection, [ref]$parsedSelection)) {
        Write-SQTLog "Invalid selection." "ERROR"
        return
    }

    $index = $parsedSelection - 1

    if ($index -lt 0 -or $index -ge $devices.Count) {
        Write-SQTLog "Invalid selection." "ERROR"
        return
    }

    $removed = $devices[$index]
    $remainingDevices = @($devices | Where-Object { $_.IP -ne $removed.IP -or $_.Name -ne $removed.Name })

    Save-SQTDevices -Devices $remainingDevices

    $config = Get-SQTConfig
    if ($config.CurrentDevice -eq $removed.IP -or $config.CurrentDevice -eq "$($removed.IP):5555") {
        Set-SQTCurrentDevice -Name "" -IP ""
    }

    Write-SQTLog "Device removed successfully." "SUCCESS"

}

function Select-SQTDevice {

    $devices = Get-SQTDeviceList

    if ($devices.Count -eq 0) {
        Write-SQTLog "No saved devices found." "WARNING"
        return
    }

    Clear-Host

    Write-Host ""
    Write-Host "Select Saved Device"
    Write-Host "-------------------"

    $i = 1
    foreach ($device in $devices) {
        $label = if ($device.Name) { $device.Name } else { "Unnamed" }
        Write-Host "$i. $label - $($device.IP)"
        $i++
    }

    $selection = Read-Host "Select device number"
    $index = [int]$selection - 1

    if ($selection -notmatch '^\d+$' -or $index -lt 0 -or $index -ge $devices.Count) {
        Write-SQTLog "Invalid selection." "ERROR"
        return
    }

    $selected = $devices[$index]

    try {
        $result = Connect-SQTADB -IP $selected.IP

        if ($result -match "connected" -or $result -match "already connected" -or $result -match "already exists") {
            Set-SQTCurrentDevice -Name $selected.Name -IP $selected.IP
            Write-SQTLog "Selected device: $($selected.Name) ($($selected.IP))." "SUCCESS"
        }
        else {
            Write-SQTLog "Failed to connect to selected device." "ERROR"
        }
    }
    catch {
        Write-SQTLog "Connection failed: $($_.Exception.Message)" "ERROR"
    }

}

function Connect-NewSQTDevice {

    Clear-Host

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "           CONNECT DEVICE"
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    $ip = (Read-Host "Enter Device IP").Trim()

    if ([string]::IsNullOrWhiteSpace($ip)) {
        Write-SQTLog "No IP entered." "ERROR"
        return
    }

    try {
        Write-SQTLog "Starting ADB Server..."
        Start-SQTADBServer

        Write-SQTLog "Connecting to $ip..."
        $result = Connect-SQTADB -IP $ip

        Write-Host ""
        Write-Host $result

        if ($result -match "connected" -or $result -match "already connected" -or $result -match "already exists") {
            $devices = Get-SQTDeviceList
            $existing = $devices | Where-Object { $_.IP -eq $ip }

            if (-not $existing) {
                $devices += [PSCustomObject]@{
                    Name = $ip
                    IP   = $ip
                }
                Save-SQTDevices -Devices $devices
            }

            Set-SQTCurrentDevice -Name $ip -IP $ip
            Write-SQTLog "Connected successfully." "SUCCESS"
        }
        else {
            Write-SQTLog "Connection failed." "ERROR"
        }
    }
    catch {
        Write-SQTLog "Connection failed: $($_.Exception.Message)" "ERROR"
    }

}

function Test-SQTConnection {

    Clear-Host

    $config = Get-SQTConfig

    if ([string]::IsNullOrWhiteSpace($config.CurrentDevice)) {
        Write-SQTLog "No current device selected." "ERROR"
        return
    }

    Write-SQTLog "Testing connection..."

    try {
        $devices = @(Get-SQTConnectedDevices)
        $found = $false

        foreach ($device in $devices) {
            if ($device -match [regex]::Escape($config.CurrentDevice) -or $device -match [regex]::Escape("$($config.CurrentDevice):5555")) {
                $found = $true
                break
            }
        }

        if ($found) {
            Write-SQTLog "Device is Connected." "SUCCESS"
        }
        else {
            Write-SQTLog "Device is Offline." "ERROR"
        }
    }
    catch {
        Write-SQTLog "Unable to test connection: $($_.Exception.Message)" "ERROR"
    }

}

function Show-SQTConnectedDevices {

    Clear-Host

    Write-Host ""
    Write-Host "Connected Devices"
    Write-Host "-----------------"

    try {
        $devices = @(Get-SQTConnectedDevices)

        if ($devices.Count -eq 0) {
            Write-Host ""
            Write-Host "No Devices Connected."
        }
        else {
            foreach ($device in $devices) {
                Write-Host $device
            }
        }
    }
    catch {
        Write-SQTLog "Unable to read connected devices: $($_.Exception.Message)" "ERROR"
    }

}

function Disconnect-SQTDevice {

    # Get list of connected devices from adb
    try {
        $connected = @(Get-SQTConnectedDevices)
    }
    catch {
        Write-SQTLog "Unable to retrieve connected devices: $($_.Exception.Message)" "ERROR"
        return
    }

    if ($connected.Count -eq 0) {
        Write-SQTLog "No devices are currently connected." "INFO"
        return
    }

    # Parse lines to extract the device identifier (first token)
    $items = @()
    foreach ($line in $connected) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $token = ($line -split '\s+')[0]
        $items += $token
    }

    if ($items.Count -eq 1) {
        $choiceIndex = 0
    }
    else {
        Clear-Host
        Write-Host ""
        Write-Host "Select device to disconnect"
        Write-Host "---------------------------"
        for ($i = 0; $i -lt $items.Count; $i++) {
            Write-Host "$(($i + 1)). $($items[$i])"
        }

        $selection = Read-Host "Select device number"
        $parsed = 0
        if (-not [int]::TryParse($selection, [ref]$parsed)) {
            Write-SQTLog "Invalid selection." "ERROR"
            return
        }

        $choiceIndex = $parsed - 1
        if ($choiceIndex -lt 0 -or $choiceIndex -ge $items.Count) {
            Write-SQTLog "Invalid selection." "ERROR"
            return
        }
    }

    $selectedToken = $items[$choiceIndex]

    # Normalize IP (strip port if present)
    $ip = $selectedToken
    if ($ip -match ':') {
        $ip = $ip.Split(':')[0]
    }

    try {
        Write-SQTLog "Disconnecting $selectedToken..."
        $result = Disconnect-SQTADB -IP $ip

        Write-Host ""
        Write-Host $result

        if ($result -match "disconnected" -or $result -match "not connected" -or $result -match "already disconnected" -or $result -match "cannot") {
            $config = Get-SQTConfig
            if ($config.CurrentDevice) {
                $cur = $config.CurrentDevice
                if ($cur -match ':') { $curVal = $cur.Split(':')[0] } else { $curVal = $cur }
                if ($curVal -eq $ip) {
                    Set-SQTCurrentDevice -Name "" -IP ""
                }
            }

            Write-SQTLog "Device disconnected." "SUCCESS"
        }
        else {
            Write-SQTLog "Disconnect result: $result" "WARNING"
        }
    }
    catch {
        Write-SQTLog "Failed to disconnect: $($_.Exception.Message)" "ERROR"
    }

}