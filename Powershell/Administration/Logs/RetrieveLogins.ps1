# Define the username to search for
$username = "XXX"

# Define the start date (e.g., 2 weeks ago)
$startDate = (Get-Date).AddDays(-14)  # Adjust the number of days as needed

# Query the Security log for logon events (Event ID 4624) since the specified start date for the specific user
$logonEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'Security';
    Id = 4624;
    StartTime = $startDate
} | Where-Object {
    $_.Properties[5].Value -eq $username
} | Select-Object -Property TimeCreated, @{Name='Username';Expression={$_.Properties[5].Value}}

# Output the logon events
$logonEvents | Format-Table -AutoSize