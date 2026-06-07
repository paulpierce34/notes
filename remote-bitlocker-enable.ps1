## Change this to target PC and then execute
$RemoteComputer = "new-desktop"





## Do not make changes below
$Outfilepath = "$env:USERPROFILE\Documents\recovery-keys.txt"
$credential = Get-credential
invoke-command -computername $RemoteComputer -credential $credential -scriptblock {

write-output "============================"
hostname
write-output "============================"

write-output "Bitlocker status before changes:"
Get-Bitlockervolume -MountPoint "C:"

write-output "`n`nEncrypting volume with command: Enable-Bitlocker -MountPoint 'C:' -SkipHardwareTest -EncryptionMethod Aes256 -UsedSpaceOnly -TpmProtector"
Enable-Bitlocker -MountPoint "C:" -SkipHardwareTest -EncryptionMethod Aes256 -UsedSpaceOnly -TpmProtector

write-output "`n`nRetrieving keys..."
(Get-Bitlockervolume -Mountpoint "C:" | Select KeyProtector).KeyProtector.RecoveryPassword

write-output "`n`nBitlocker status AFTER changes (Volume status should read EncryptionInProgress or FullyEncrypted):"
Get-Bitlockervolume -MountPoint "C:"

} >> $Outfilepath

if (Test-Path $Outfilepath){
write-host -ForegroundColor Yellow "`nContents of file:`n"
Get-content $Outfilepath
write-host -foregroundcolor Green "`nSuccessfully created output file here: $Outfilepath"
}


