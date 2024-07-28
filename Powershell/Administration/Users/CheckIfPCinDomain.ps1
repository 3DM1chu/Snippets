$domainInfo = systeminfo | Select-String -Pattern "^Domain"

# Check if the computer is in a workgroup
if ($domainInfo -match 'WORKGROUP') {
    Write-Host "The computer is in a workgroup."
    return
} else {
    Write-Host "PC is in domain, continue..."
}