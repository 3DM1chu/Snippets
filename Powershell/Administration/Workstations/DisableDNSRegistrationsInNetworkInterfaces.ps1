$networkInterface = Get-NetAdapter -Name "*ZeroTier*"
$networkInterface | ForEach-Object {
	# Disable DNS registration
	Write-Host "Disabling DNS registration for interface"
	$_ | Select Name
	Set-DnsClient -InterfaceIndex $_.ifIndex -RegisterThisConnectionsAddress $false
}