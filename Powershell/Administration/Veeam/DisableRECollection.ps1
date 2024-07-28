$registryKeyPath = "HKLM:\SOFTWARE\Veeam\Veeam EndPoint Backup"
$valueName = "DisableRECollection"
$valueData = 1

# Check if the registry value exists
if (Test-Path -Path $registryKeyPath) {
    $existingValue = Get-ItemProperty -Path $registryKeyPath -Name $valueName -ErrorAction SilentlyContinue
    if ($existingValue -eq $null) {
        # If the value doesn't exist, create it
        New-ItemProperty -Path $registryKeyPath -Name $valueName -Value $valueData -PropertyType DWORD -Force | Out-Null
    } elseif ($existingValue.$valueName -ne $valueData) { # if not set to 1
        # If the value exists but is different, update it
        Set-ItemProperty -Path $registryKeyPath -Name $valueName -Value $valueData -Type DWORD -Force
    }
} else {
    # If the registry key doesn't exist, create it along with the value
    New-Item -Path $registryKeyPath -Force | Out-Null
    New-ItemProperty -Path $registryKeyPath -Name $valueName -Value $valueData -PropertyType DWORD -Force | Out-Null
}

# Restart Veeam Agent for Microsoft Windows service
Restart-Service -Name VeeamEndpointBackupSvc -Force
