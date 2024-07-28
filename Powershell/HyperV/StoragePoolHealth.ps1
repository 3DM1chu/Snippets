# Get all virtual disks
$allVirtualDisks = Get-VirtualDisk

# Iterate through each virtual disk
foreach ($virtualDisk in $allVirtualDisks) {
    # Specify the friendly name of the Storage Pool for the current virtual disk
    $desiredStoragePoolFriendlyName = ($virtualDisk | Get-StoragePool | Select-Object -ExpandProperty FriendlyName)
	$operationalStatus = $virtualDisk.OperationalStatus

    # Display information about the current virtual disk
    Write-Host "Virtual Disk: $($virtualDisk.FriendlyName)"
    $sizeGB = [math]::Round(($virtualDisk.Size / 1GB), 2)
    Write-Host "   HealthStatus: $($virtualDisk.HealthStatus)"
    Write-Host "   OperationalStatus: $operationalStatus"

    # Calculate used and free space for the virtual disk
    $usedSpaceGB = [math]::Round(($virtualDisk.Size - $virtualDisk.FreeSpace) / 1GB, 2)
    $freeSpaceGB = [math]::Round($virtualDisk.FreeSpace / 1GB, 2)
    $usedSpacePercentage = [math]::Round(($usedSpaceGB / $sizeGB) * 100, 2)

    Write-Host "   Used Space: $($usedSpaceGB) GB ($($usedSpacePercentage)%)"
	
	if ($operationalStatus -eq "Healthy" -or $operationalStatus -eq "OK" -or $operationalStatus -eq "Online" -or $operationalStatus -eq "Normal" -or $virtualDisk.HealthStatus -ne "Healthy") {
        Write-Host "	Health checks OK"
    } else {
        Write-Host "		HEALTH CHECKS NOT OK, ALERT!!!!!!!!"
        $returnCode = 20
    }
	
    Write-Host "   -------------------------"
	

    # Get the Storage Pool based on the friendly name
    $storagePool = Get-StoragePool -FriendlyName $desiredStoragePoolFriendlyName

    # Check if the Storage Pool was found
    if ($storagePool -ne $null) {
        $storagePoolFriendlyName = $storagePool.FriendlyName
		$operationalStatus = $storagePool.OperationalStatus
        Write-Host "Storage Pool found:"
        Write-Host "   Friendly Name: $($storagePoolFriendlyName)"
        Write-Host "   OperationalStatus: $operationalStatus"
        Write-Host "   HealthStatus: $($storagePool.HealthStatus)"
		
		if ($operationalStatus -eq "Healthy" -or $operationalStatus -eq "OK" -or $operationalStatus -eq "Online" -or $operationalStatus -eq "Normal" -or $storagePool.HealthStatus -ne "Healthy") {
			Write-Host "	Health checks OK"
		} else {
			Write-Host "		HEALTH CHECKS NOT OK, ALERT!!!!!!!!"
			$returnCode = 20
		}
		
        Write-Host "   -------------------------"

        # Get the physical disks assigned to the storage pool
        $physicalDisks = Get-StoragePool -FriendlyName $storagePoolFriendlyName | Get-PhysicalDisk

        # Display information about the physical disks
        foreach ($disk in $physicalDisks) {
            Write-Host "Physical Disk: $($disk.FriendlyName)"
            $physicalSizeGB = [math]::Round(($disk.Size / 1GB), 2)
			$operationalStatus = $disk.OperationalStatus
            Write-Host "   HealthStatus: $($disk.HealthStatus)"
            Write-Host "   OperationalStatus: $($disk.OperationalStatus)"

            # Calculate used and free space for the physical disk
            $physicalUsedSpaceGB = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
            $physicalFreeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
            $physicalUsedSpacePercentage = [math]::Round(($physicalUsedSpaceGB / $physicalSizeGB) * 100, 2)

            Write-Host "   Used Space: $($physicalUsedSpaceGB) GB ($($physicalUsedSpacePercentage)%)"
			
			if ($operationalStatus -eq "Healthy" -or $operationalStatus -eq "OK" -or $operationalStatus -eq "Online" -or $operationalStatus -eq "Normal" -or $disk.HealthStatus -ne "Healthy") {
				Write-Host "	Health checks OK"
			} else {
				Write-Host "		HEALTH CHECKS NOT OK, ALERT!!!!!!!!"
				$returnCode = 20
			}
			
            Write-Host "   -------------------------"
        }

        # Add any additional information or actions you want to perform with the found Storage Pool
    } else {
        Write-Host "Storage Pool with friendly name '$desiredStoragePoolFriendlyName' not found."
    }

    Write-Host "================================="
}
