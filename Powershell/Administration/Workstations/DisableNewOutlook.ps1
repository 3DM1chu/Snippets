# Define the content of your .reg file as a string
$regContent = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook\Options\General]
"HideNewOutlookToggle"=dword:00000001
"@

# Save the content to a temporary .reg file
$regFilePath = [System.IO.Path]::GetTempFileName() + ".reg"
$regContent | Out-File -FilePath $regFilePath -Encoding ASCII

# Use regedit.exe to import the .reg file silently
Start-Process regedit.exe -ArgumentList "/s $regFilePath" -Wait

# Clean up: delete the temporary .reg file
Remove-Item -Path $regFilePath