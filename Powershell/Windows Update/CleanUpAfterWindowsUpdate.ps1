param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string[]]$Section
)

$sections = @(
    'Active Setup Temp Folders',
    'BranchCache',
    'Content Indexer Cleaner',
    'Downloaded Program Files',
    'GameNewsFiles',
    'GameStatisticsFiles',
    'GameUpdateFiles',
    'Internet Cache Files',
    'Memory Dump Files',
    'Offline Pages Files',
    'Old ChkDsk Files',
    'Previous Installations',
    'Service Pack Cleanup',
    'Setup Log Files',
    'System error memory dump files',
    'System error minidump files',
    'Temporary Files',
    'Temporary Setup Files',
    'Temporary Sync Files',
    'Update Cleanup',
    'Upgrade Discarded Files',
    'Windows Defender',
    'Windows Error Reporting Archive Files',
    'Windows Error Reporting Queue Files',
    'Windows Error Reporting System Archive Files',
    'Windows Error Reporting System Queue Files',
    'Windows ESD installation files',
    'Windows Upgrade Log Files'
)

if ($PSBoundParameters.ContainsKey('Section')) {
    if ($Section -notin $sections) {
        throw "The section [$($Section)] is not available. Available options are: [$($Section -join ',')]."
    }
} else {
    $Section = $sections
}

Write-Verbose -Message 'Clearing CleanMgr.exe automation settings.'

$getItemParams = @{
    Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*'
    Name        = 'StateFlags0064'
    ErrorAction = 'SilentlyContinue'
}
Get-ItemProperty @getItemParams | Remove-ItemProperty -Name StateFlags0064 -ErrorAction SilentlyContinue

Write-Verbose -Message 'Adding enabled disk cleanup sections...'
foreach ($keyName in $Section) {
    $newItemParams = @{
        Path         = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$keyName"
        Name         = 'StateFlags0064'
        Value        = 2
        PropertyType = 'DWord'
        ErrorAction  = 'SilentlyContinue'
    }
    $null = New-ItemProperty @newItemParams
}

Write-Verbose -Message 'Starting CleanMgr.exe...'
Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:64' -NoNewWindow -Wait

Write-Verbose -Message 'Waiting for CleanMgr and DismHost processes...'
Get-Process -Name cleanmgr, dismhost -ErrorAction SilentlyContinue | Wait-Process

Function Set-WindowsUpdateService{
    Write-Host "Deleting files from 'C:\Windows\SoftwareDistribution\'" -ForegroundColor Yellow
    
    
        Try{
            Get-Service -Name wuauserv | Stop-Service -Force -ErrorAction Stop
            $WUpdateError = $false
        }
        Catch [System.Exception]{
            $WUpdateError = $true
        }
        Finally{
            If($WUpdateError -eq $False){
                Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -force -recurse -ErrorAction SilentlyContinue    
                Get-Service -Name wuauserv | Start-Service
                Write-Host "Files Deleted Successfully" -ForegroundColor Green
            }
            Else{
                Get-Service -Name wuauserv | Start-Service
                Write-Host "Unable to stop the windows update service. No files were deleted." -ForegroundColor Red
            }
        }
}
Set-WindowsUpdateService
// usuwa folder SoftwareDistribution