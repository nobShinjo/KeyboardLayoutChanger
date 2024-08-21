# Function to get HID of connected keyboards
function Get-KeyboardHIDs {
    param ($initialKeyboards = @())
    $keyboards = Get-PnpDevice -Class Keyboard
    $currentKeyboards = $keyboards | Where-Object { $_.Status -eq 'OK' -and $_.InstanceId }
    if ($initialKeyboards.Count -eq 0) {
        $newKeyboards = $currentKeyboards
    }
    else {
        $newKeyboards = $currentKeyboards | Where-Object { $_.InstanceId -notin $initialKeyboards.InstanceId }
    }
    $newKeyboards | ForEach-Object {
        [PSCustomObject]@{
            Name       = $_.Name
            InstanceId = $_.InstanceId
        }
    }
}

# Get all currently connected keyboard devices
Write-Output "Getting initial list of connected keyboards..."
$initialKeyboards = Get-KeyboardHIDs

# Display currently connected keyboards
if ($initialKeyboards) {
    Write-Output "Currently connected keyboards:"
    $initialKeyboards | ForEach-Object { Write-Output " - $($_.Name): ($($_.InstanceId))" }
}
else {
    Write-Error "No keyboards currently connected."
    exit 1
}

# Monitor for new keyboard connections
$timeoutSeconds = 60
$elapsedSeconds = 0

while ($true) {
    Write-Output "Checking for new keyboard connections..."
    Start-Sleep -Seconds 5
    $elapsedSeconds += 5
    $hids = Get-KeyboardHIDs -initialKeyboards $initialKeyboards
    if ($hids) {
        Write-Output "New keyboard detected with the following HIDs:"
        $hids | ForEach-Object { Write-Output " - $($_.Name): ($($_.InstanceId))" }
        break
    }
    if ($elapsedSeconds -ge $timeoutSeconds) {
        Write-Output "Timeout reached. No new keyboard detected."
        break
    }
    Write-Output "Waiting for new keyboard connection... ($elapsedSeconds seconds elapsed)"
}

if (-not $hids) {
    Write-Error "No new keyboard detected within the timeout period."
    exit 1
}

# Prompt user for desired keyboard layout
$layout = Read-Host "Enter the desired keyboard layout (JIS/US):"

# Determine the corresponding values for KeyboardSubtypeOverride and KeyboardTypeOverride
switch ($layout) {
    "JIS" {
        $keyboardSubtypeOverride = "00000002"
        $keyboardTypeOverride = "00000007"
    }
    "US" {
        $keyboardSubtypeOverride = "00000000"
        $keyboardTypeOverride = "00000007"
    }
    default {
        Write-Warning "Invalid layout. Exiting."
        exit 1
    }
}

# Generate registry modification code
if ($hids -and $hids.Count -gt 0) {
    $registryCode = @"
Windows Registry Editor Version 5.00

; Automatically generated registry changes for keyboard layout

"@

    # Add registry changes for i8042prt parameters
    $registryCode += @"
; i8042prt parameters for keyboard layout override (JIS/US)
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters]
"OverrideKeyboardIdentifier"="PCAT_101KEY"
"OverrideKeyboardSubtype"=-
"OverrideKeyboardType"=-

"@

    $registryCode += @"

; Device parameters for keyboard layout override (JIS/US)


"@

    foreach ($hid in $hids) {
        $registryCode += @"
; Keyboard layout override for $($hid.InstanceId)
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\$($hid.InstanceId)\Device Parameters]
"KeyboardSubtypeOverride"=dword:$keyboardSubtypeOverride
"KeyboardTypeOverride"=dword:$keyboardTypeOverride


"@
    }

    

    # Output the registry modification code to a .reg file in the current directory
    $registryFilePath = Join-Path -Path (Get-Location) -ChildPath "keyboard_layout_change.reg"
    $registryCode | Out-File -FilePath $registryFilePath -Encoding ASCII

    Write-Output "Registry modification code has been saved to $registryFilePath"
}
else {
    Write-Output "No new keyboards detected. No registry changes made."
}
