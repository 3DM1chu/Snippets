$base_directory = "D:\Users"
$regex_pattern = '(?<=id\d.useremail", ")\w+'

function Find-PrefsJS {
    param([string]$directory)
    
    $prefsJSFiles = Get-ChildItem -Recurse -File -Path $directory -Filter "prefs.js"
    if ($prefsJSFiles.Count -gt 0) {
        $prefsJSFiles | ForEach-Object {
            $prefsFileContent = Get-Content $_.FullName -Raw
            $matches = [regex]::Matches($prefsFileContent, $regex_pattern)
            if ($matches.Count -gt 0) {
                Write-Output "$($_.FullName)"
                $matches | ForEach-Object {
                    Write-Output $_.Value
                }
                Write-Output "==============================="
            }
        }
    }
}

function Find-ThunderbirdProfiles {
    param([string]$directory)
    
    Get-ChildItem -Recurse -Directory -Path $directory | ForEach-Object {
        $profilePath = Join-Path $_.FullName "AppData\Roaming\Thunderbird\Profiles"
        if (Test-Path $profilePath) {
            Find-PrefsJS -directory $profilePath
        }
    }
}

Find-ThunderbirdProfiles -directory $base_directory