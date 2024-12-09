function Get-BrowserProfile {
    <#
    .SYNOPSIS
        Query Browser Profiles
    .DESCRIPTION
        Query Browser profiles, returning ID, Name and UserName. For current user or all users
    .PARAMETER Browser
        Optional. Browser app to target for query (if installed)
        * Default = Get default browser from registry query
        * Chrome
        * Edge
        * Brave
        * Firefox
    .PARAMETER AllUsers
        Query all users on the computer
    .EXAMPLE
        Get-BrowserProfile
    .EXAMPLE
        Get-BrowserProfile -Browser Edge
    .EXAMPLE
        Get-BrowserProfile -Browser Chrome -AllUsers
    .LINK
        https://github.com/Skatterbrainz/helium/blob/master/docs/Get-BrowserProfile.md
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False)][string][ValidateSet('Chrome','Edge','Brave','Firefox','Default')]$Browser = 'Default',
        [parameter(Mandatory=$False)][switch]$AllUsers
    )
    if (!$AllUsers) {
        if ($Browser -eq 'Default') {
            $app = Get-DefaultBrowser
        } else {
            $app = $Browser
        }
        switch ($app) {
            'Chrome' {
                $profilePath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
                [array]$profileFolders = Get-ChildItem -Path $profilePath -Directory -Filter "Profile*" | select-object Name,FullName
            }
            'Brave' {
                $profilePath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"
                [array]$profileFolders = Get-ChildItem -Path $profilePath -Directory -Filter "Profile*" | select-object Name,FullName
            }
            'Edge' {
                $profilePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
                [array]$profileFolders = Get-ChildItem -Path $profilePath -Directory -Filter "Profile*" | select-object Name,FullName
            }
            'Firefox' {
                $profilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
                [array]$profileFolders = Get-ChildItem -Path $profilePath -Directory | select-object Name,FullName
            }
        }
        if ($app -ne 'Firefox') {
            foreach ($folder in $profileFolders) {
                [string]$pref = Join-Path $folder.FullName "Preferences"
                if (Test-Path $pref) {
                    $prefdata = Get-Content $pref -Raw | ConvertFrom-Json
                    $name = $prefdata.profile.name
                    [pscustomobject]@{
                        UserName    = $env:USERNAME
                        ProfileID   = $folder.Name
                        ProfileName = $name
                        Browser     = $app
                    }
                }
            }
        } else {
            foreach ($folder in $profileFolders) {
                $prefdata = $folder.Name.Split('.')
                $name = $prefdata[1]
                [pscustomobject]@{
                    UserName    = $env:USERNAME
                    ProfileID   = $folder.Name
                    ProfileName = $name
                    Browser     = $app
                }
            }
        }
    } else {
        $exclude = @('AppData','Public')
        if ($Browser -eq 'Default') {
            $app = Get-DefaultBrowser
        } else {
            $app = $Browser
        }
        switch ($app) {
            'Chrome' {
                $profileSub = "AppData\Google\Chrome\User Data"
            }
            'Brave' {
                $profileSub = "AppData\Local\BraveSoftware\Brave-Browser\User Data"
            }
            'Edge' {
                $profileSub = "AppData\Local\Microsoft\Edge\User Data"
            }
            'Firefox' {
                $profileSub = 'AppData\Local\Mozilla\Firefox\Profiles'
            }
        }
        [array]$userprofiles = Get-ChildItem -Path "c:\users" -Directory | Where-Object {$_.name -notin $exclude} | Select-Object Name,FullName
        Write-Verbose "$($userprofiles.Count) user profiles found"
        foreach ($userpath in $userprofiles) {
            $profilePath = Join-Path $($userpath.FullName) $profileSub
            Write-Verbose "reading: $profilePath"
            if ($app -ne 'Firefox') {
                [array]$profileFolders = Get-ChildItem -Path $profilePath -Directory -Filter "Profile*" | select-object Name,FullName
                foreach ($folder in $profileFolders) {
                    [string]$pref = Join-Path $folder.FullName "Preferences"
                    if (Test-Path $pref) {
                        $prefdata = Get-Content $pref -Raw | ConvertFrom-Json
                        $name = $prefdata.profile.name
                        [pscustomobject]@{
                            UserName    = $userpath.Name
                            ProfileID   = $folder.Name
                            ProfileName = $name
                            Browser     = $app
                        }
                    }
                }
            } else {
                [array]$profileFolders = Get-ChildItem -Path $profilePath -Directory | select-object Name,FullName
                foreach ($folder in $profileFolders) {
                    $prefdata = $folder.Name.Split('.')
                    $name = $prefdata[1]
                    [pscustomobject]@{
                        UserName    = $env:USERNAME
                        ProfileID   = $folder.Name
                        ProfileName = $name
                        Browser     = $app
                    }
                }
            }
        }
    }
}

Function Cleanup { 
<# 
.CREATED BY: 
    Matthew A. Kerfoot 
.CREATED ON: 
    10\17\2013 
.Synopsis 
   Windows 10 Clean up and speed up
.DESCRIPTION 
   Cleans the C: drive's Window Temperary files, Windows SoftwareDistribution folder, `
   the local users Temperary folder, IIS logs(if applicable) and empties the recycling bin. `
   All deleted files will go into a log transcript in C:\Windows\Temp\. By default this `
   script leaves files that are newer than 7 days old however this variable can be edited. 
.EXAMPLE 
   PS C:\Users\mkerfoot\Desktop\Powershell> .\cleanup_log.ps1 
   Save the file to your desktop with a .PS1 extention and run the file from an elavated PowerShell prompt. 
.NOTES 
   This script will typically clean up anywhere from 1GB up to 15GB of space from a C: drive. 
.FUNCTIONALITY 
   PowerShell v3 
#> 
function global:Write-Verbose ( [string]$Message ) 
# check $VerbosePreference variable, and turns -Verbose on 
{ if ( $VerbosePreference -ne 'SilentlyContinue' ) 
{ Write-Host " $Message" -ForegroundColor 'Yellow' } } 
$VerbosePreference = "Continue" 
$DaysToDelete = 0 
$LogDate = get-date -format "MM-d-yy-HH" 
$objShell = New-Object -ComObject Shell.Application  
$objFolder = $objShell.Namespace(0xA) 
$ErrorActionPreference = "silentlycontinue" 
Start-Transcript -Path C:\Windows\Temp\$LogDate.log -Verbose
## Cleans all code off of the screen. 
Clear-Host 
$size = Get-ChildItem C:\Users\* -Include *.iso, *.vhd -Recurse -ErrorAction SilentlyContinue |  
Sort-Object Length -Descending |  
Select-Object Name, 
@{Name="Size (GB)";Expression={ "{0:N2}" -f ($_.Length / 1GB) }}, Directory | 
Format-Table -AutoSize | Out-String 
$Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName, 
@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } }, 
@{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, 
@{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } }, 
@{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } | 
Format-Table -AutoSize | Out-String                       
## Stops the windows update service.  
Get-Service -Name wuauserv | Stop-Service -Force -Verbose -ErrorAction SilentlyContinue 
## Windows Update Service has been stopped successfully! 
## Deletes the contents of windows software distribution. 
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The Contents of Windows SoftwareDistribution have been removed successfully! 
## Deletes the contents of the Windows Temp folder. 
Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete)) } | 
remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The Contents of Windows Temp have been removed successfully! 
## Delets all files and folders in user's Temp folder.  
Get-ChildItem "C:\users\*\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | 
Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete))} | 
remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The contents of C:\users\$env:USERNAME\AppData\Local\Temp\ have been removed successfully! 
## Remove all files and folders in user's Temporary Internet Files.  
Get-ChildItem "C:\users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" `
-Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
Where-Object {($_.CreationTime -le $(Get-Date).AddDays(-$DaysToDelete))} | 
remove-item -force -recurse -ErrorAction SilentlyContinue 

## Delets all files and folders in user's Temp folder.  
#Get-ChildItem "$env:LOCALAPPDATA\Google\Chrome\User Data\*" -Recurse -Force -ErrorAction SilentlyContinue | 
#Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete))} | 
#remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 

## Part for Chrome temp folders
$ChromeProfileNames = @(
"Profile 1",                                                                                            
"Profile 3",                                                                                            
"Profile 6",                                                                                            
"Profile 7",                                                                                            
"Profile 8"
<#,
"Default" #>
)

$ChromeProfileFolder = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\"
$ChromeProfileNames | ForEach-Object { 
    if (Test-Path "$ChromeProfileFolder\$_") {
            Get-ChildItem -Path "$ChromeProfileFolder\$_" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Cache\*" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Archived History\*" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\History\*" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Top Sites\*" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Visited Links\*" | Where-Object { $_.Name -notlike "*Bookmarks*" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Web Data\*" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Cache\*" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Cache2\entries\*" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Cookies" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Media Cache" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem -path "$ChromeProfileFolder\$_\Cookies-Journal" | Where-Object { $_.Name -ne "Bookmarks" } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
    }
    }

## Remove all files and folders in user's INetCache.  
Get-ChildItem "C:\users\*\AppData\Local\Microsoft\Windows\INetCache\*" `
-Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
Where-Object {($_.CreationTime -le $(Get-Date).AddDays(-$DaysToDelete))} | 
remove-item -force -recurse -ErrorAction SilentlyContinue 
#C:\users\a767818\AppData\Local\Temp

## All Temporary Internet Files have been removed successfully! 
## Cleans IIS Logs if applicable. 
Get-ChildItem "C:\inetpub\logs\LogFiles\*" -Recurse -Force -ErrorAction SilentlyContinue | 
Where-Object { ($_.CreationTime -le $(Get-Date).AddDays(-$DaysToDelete)) } | 
Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue 
## All IIS Logfiles over x days old have been removed Successfully! 
## deletes the contents of the recycling Bin. 
## The Recycling Bin is now being emptied! 
$objFolder.items() | ForEach-Object { Remove-Item $_.path -ErrorAction Ignore -Force -Verbose -Recurse } 
## The Recycling Bin has been emptied! 
<#
## Clean up Chrome files
$Items = @('Archived History',
            'Cache\*',
            'Cookies',
            'History',
            'Login Data',
            'Top Sites',
            'Visited Links',
            'Web Data')
$Folder = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default"
$Items | ForEach-Object { 
    if (Test-Path "$Folder\$_") {
        Remove-Item "$Folder\$_" -Force -Verbose -Recurse -ErrorAction SilentlyContinue 
    }
}
#>

##
$After =  Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName, 
@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } }, 
@{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, 
@{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } }, 
@{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } | 
Format-Table -AutoSize | Out-String 
## Sends some before and after info for ticketing purposes 
Hostname ; Get-Date | Select-Object DateTime 
Write-Verbose "Before: $Before" 
Write-Verbose "After: $After" 
Write-Verbose $size 
## Completed Successfully! 
## Starts the windows update service.  
Get-Service -Name wuauserv | Start-Service -Verbose -ErrorAction SilentlyContinue 
## Windows Update Service has been Started successfully! 
}
$currentDate = Get-Date
Write-Host "Current date and time: $currentDate"

#Get-BrowserProfile

Cleanup

Stop-Transcript 
Start-Sleep -Seconds 20