## NOTE: Leave this RemoteComputer variable blank to reference host file if targeting numerous hosts: C:\Users\<username>\Documents\hosts.txt

## Set to new-desktop as an example, if you were to target one host

$RemoteComputer = "new-desktop"














## Do not make changes below

# $Outfilepath = "$env:USERPROFILE\Documents\" + $TodayDate + "-" + "extension-logs.txt"


$hostsfile = "$env:USERPROFILE\Documents\hosts.txt"
$completedhostsfile = "$env:USERPROFILE\Documents\completed-hosts.txt"


## Create local hosts and completed hosts files
if (!(Test-Path $hostsfile)){
write-host "hosts.txt not detected. creating hosts file"
pause
New-Item -Path $hostsfile
}

if (!(Test-Path $completedhostsfile)){
write-host "completedhosts.txt not detected. creating completed-hosts file"
pause
New-Item -Path $completedhostsfile
}





$AllComputers = Get-Content -Path $hostsfile
$CompletedComputers = Get-Content -Path $completedhostsfile





$credential = Get-credential
$TodayDate = Get-Date -Format yyyy-MM-dd



write-host -foregroundcolor cyan "Hosts detected in hosts file: $AllComputers"
if ($RemoteComputer -ne ""){

$AllComputers = $RemoteComputer
write-host "Detected hosts in RemoteComputer variable. Bypassing hosts list"

}
else {

write-host "Remote computer variable not configured... attempting to open hosts file."

}




Foreach ($SingleComputer in $AllComputers){

$Outfilepath = "$env:USERPROFILE\Documents\" + $TodayDate + "-" + $SingleComputer + "extension-logs.txt"


if ($Allcomputers -ne $null -and $CompletedComputers -notcontains $Singlecomputer){

write-host "$Singlecomputer not detected in completed hosts file, targeting this machine for script execution."


try {
Invoke-Command -Computername $SingleComputer -Credential $Credential -ErrorVariable ConnectionError -Scriptblock {

write-output "=======================================`n"


## Define registry paths
$ChromePath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist"
$EdgePath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallBlocklist"
$OneDrivePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
$CoPilotPath = "HKLM:\Software\Policies\Microsoft\Windows\WindowsCopilot"
$AIPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
$PhoneLinkPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Mobility"


### Chrome section
write-output "Disabling Chrome extensions......`n`n"

if (!(Test-Path $ChromePath)) {
New-Item -Path $ChromePath -Force
}
else {
write-output "Chrome parent folder detected. Skipping creation step."
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist" -Name "1" -Value "*" -PropertyType String


### Edge section
write-output "Disabling Edge extensions.....`n`n"

if (!(Test-Path $EdgePath)) {
New-Item -Path $EdgePath -Force
}
else {
write-output "MS Edge registry parent folder detected. Skipping creation step."
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallBlocklist" -Name "1" -Value "*" -PropertyType String


### Onedrive section
write-output "Preventing the use of OneDrive for file storage....`n`n"

if (!(Test-Path $OneDrivePath)) {
New-Item -Path $OneDrivePath -Force
}
else {
write-output "OneDrive registry parent folder detected. Skipping creation step."
}
New-ItemProperty -Path $OneDrivePath -Name "DisableFileSyncNGSC" -Value 1 -Type DWORD



### Windows CoPilot section - Disable windows copilot
write-output "Turning off Windows CoPilot..`n`n"

if (!(Test-Path $CoPilotPath)) {
New-Item -Path $CoPilotPath -Force
}
Set-ItemProperty -Path $CoPilotPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

### Windows AI section - Removes copilot, disables/removes recall
if (!(Test-Path $AIPath)) {
New-Item -Path $AIPath -Force
}
Set-ItemProperty -Path $AIPath -Name "RemoveMicrosoftCopilotApp" -Value 1 -Type Dword -Force
Set-ItemProperty -Path $AIPath -Name "AllowRecallEnablement" -Value 0 -Type DWORD -Force
### Phone Link section

## Remove phone link application
Get-AppxPackage Microsoft.YourPhone -AllUsers | Remove-AppxPackage

## Create and set registry key
if (!(Test-Path $PhoneLinkPath)) {
New-Item -Path $PhoneLinkPath -Force
}

Set-ItemProperty -Path $PhoneLinkPath -Name "PhoneLinkEnabled" -Value 1 -Type Dword -Force


## Run a gpupdate to force current session to adopt local group policy changes
write-output "Running gpupdate command to enforce local policy modifications`n`n"
gpupdate /force

write-output "Script has completed successfully."


} >> $Outfilepath

## only write to completed hosts if the Try block succeeds
if (Select-String -Path $Outfilepath -Pattern "Script has completed successfully.") { Write-Output $SingleComputer >> $completedhostsfile }


}
catch {
    write-host -ForegroundColor Red "Failed on $SingleComputer : $($_.Exception.Message)"
}




} ## if host not found in completed-hosts file


else {

write-host -foregroundcolor yellow "Skipping detected host $Singlecomputer in completed-hosts file here: $completedhostsfile"

}

} ## foreach computer in hosts file





if (Test-Path $Outfilepath){
write-host -ForegroundColor Green "Log output filepath here: $Outfilepath"
}
else {
write-host -ForegroundColor Red "Failed to create output log file here: $Outfilepath" 
}
