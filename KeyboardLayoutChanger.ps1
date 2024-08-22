# Description: PowerShell script to change the keyboard layout for connected keyboards on Windows operating systems.
# Author: Nob Shinjo
# Date: 2024-08-22
# Version: 1.0.0
# Usage: Run the script in a PowerShell environment and follow the prompts to change the keyboard layout.
# Note: This script is designed for Windows operating systems.

# Function to get connected keyboard devices
function Get-KeyboardDevices {
    param ([PSCustomObject]$initialKeyboards = @())
    $keyboards = Get-PnpDevice -Class Keyboard
    $currentKeyboards = $keyboards | Where-Object { $_.Status -eq 'OK' -and $_.InstanceId }
    $connectedKeyboards = if ($initialKeyboards.Count -eq 0) {
        $currentKeyboards
    }
    else {
        $currentKeyboards | Where-Object { $_.InstanceId -notin $initialKeyboards.InstanceId }
    }
    $connectedKeyboards | ForEach-Object {
        [PSCustomObject]@{
            Name       = $_.Name
            InstanceId = $_.InstanceId
        }
    }
}

# Function to get KeyboardSubtypeOverride and KeyboardTypeOverride values based on layout
function Get-KeyboardLayoutValues {    
    param ([string]$layout)
    switch ($layout) {
        "JIS" {
            return @{
                KeyboardSubtypeOverride = "00000002"
                KeyboardTypeOverride    = "00000007"
            }
        }
        "US" {
            return @{
                KeyboardSubtypeOverride = "00000000"
                KeyboardTypeOverride    = "00000007"
            }
        }
        default {
            Write-Warning "Invalid layout. Exiting."
            exit 1
        }
    }
}

# Function to generate registry modification code for keyboard layout change
function New-RegistryModificationCode {
    param (
        [string]$name,
        [string]$hid,
        [PSCustomObject]$layoutValues
    )
    [string]@"
; Keyboard layout override for $($name)
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\$($hid)\Device Parameters]
"KeyboardSubtypeOverride"=dword:$($layoutValues.KeyboardSubtypeOverride)
"KeyboardTypeOverride"=dword:$($layoutValues.KeyboardTypeOverride)


"@
}


# Main script
# Disconnect all keyboards except the one with the default layout
Write-Output "Please, disconnect all keyboards except the one with the default layout."
$result = Read-Host "Are you ready to proceed? (Y/N)"
if ($result -ne "Y") {
    Write-Output "Operation canceled. Exiting."
    exit
}
    
# Get all currently connected keyboard devices
Write-Output "Getting initial list of connected keyboards..."
$existingKeyboards = Get-KeyboardDevices
    
# Display currently connected keyboards
if ($existingKeyboards) {
    Write-Output "Currently connected keyboards:"
    $existingKeyboards | ForEach-Object { Write-Output " - $($_.Name): ($($_.InstanceId))" }
}
else {
    Write-Error "No keyboards currently connected."
    exit 1
}

# Prompt user for desired keyboard layout
$layout = Read-Host "Enter the desired keyboard layout for existing keyboards (JIS/US):"
$layoutValues = Get-KeyboardLayoutValues -layout $layout

# Generate registry modification code
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

# Prompt for keyboard layout for each existing keyboard
$registryCode += "; Device parameters for exitsing keyboard layout override (JIS/US)`n"
foreach ($keyboard in $existingKeyboards) {
    $registryCode += New-RegistryModificationCode -name $keyboard.Name -hid $keyboard.InstanceId -layoutValues $layoutValues
}

# Monitor for new keyboard connections
$timeoutSeconds = 60
$elapsedSeconds = 0

while ($true) {
    Write-Output "Checking for new keyboard connections..."
    Start-Sleep -Seconds 5
    $elapsedSeconds += 5
    $newKeyboards = Get-KeyboardDevices -initialKeyboards $existingKeyboards
    if ($newKeyboards) {
        Write-Output "New keyboard detected:"
        $newKeyboards | ForEach-Object { Write-Output " - $($_.Name): ($($_.InstanceId))" }
        break
    }
    if ($elapsedSeconds -ge $timeoutSeconds) {
        Write-Output "Timeout reached. No new keyboard detected."
        exit 1
    }
    Write-Output "Waiting for new keyboard connection... ($elapsedSeconds seconds elapsed)"
}

# Prompt user for desired keyboard layout
$layout = Read-Host "Enter the desired keyboard layout (JIS/US):"

$registryCode += @"
; Device parameters for new keyboard layout override (JIS/US)

"@

$registryCode += "; Device parameters for new keyboard layout override (JIS/US)`n"
foreach ($keyboard in $newKeyboards) {
    $newlayoutValues = Get-KeyboardLayoutValues -layout $layout
    $registryCode += New-RegistryModificationCode -name $keyboard.Name -hid $keyboard.InstanceId -layoutValues $newlayoutValues
}

# Output the registry modification code to a .reg file in the current directory
$registryFilePath = Join-Path -Path (Get-Location) -ChildPath "keyboard_layout_change.reg"
$registryCode | Out-File -FilePath $registryFilePath -Encoding utf8

Write-Output "Registry modification code has been saved to $registryFilePath"
