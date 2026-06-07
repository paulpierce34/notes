## Change this to target PC and then execute
$RemoteComputer = "new-desktop"





## Do not make changes below
$Outfilepath = "$env:USERPROFILE\Documents\app-whitelisting-status.txt"
$credential = Get-credential
Invoke-Command -Computername $RemoteComputer -Credential $Credential -Scriptblock {
$OutfileLocation = "$env:USERPROFILE\Documents\signed-and-reputable.cip"

wget "https://github.com/paulpierce34/notes/raw/refs/heads/main/%7B942DF1C1-3302-4A29-B476-8D657411A94B%7D.cip" -Outfile $OutfileLocation

if (Test-Path $OutfileLocation){

write-host "Enabling and enforcing application whitelisting..."
citool -up $OutfileLocation

}
else {

write-host -ForegroundColor red "Unable to find .cip file here: $OutfileLocation"

}

write-output "Cleaning up..."
Remove-Item -Path $OutfileLocation

hostname
write-output "Active policies on system:"
citool -lp

} >> $Outfilepath

if (Test-Path $Outfilepath){

write-host -foregroundcolor green "Output log file here: $Outfilepath"

}
else {

write-host -ForegroundColor red "Failed to find output log file here: $Outfilepath"
}