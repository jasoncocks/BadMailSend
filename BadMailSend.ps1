$INETPUBHome = "C:\inetpub\mailroot"
$BadMail = "$INETPUBHome\BadMail"
$Pickup = "$INETPUBHome\Pickup"

stop-service -Name SMTPSVC

# create BadMail backup
$BadMail_Backup = "$INETPUBHome\BadMail_Backup_$(get-date -f yyyyMMddHHmmss)"

Write-Host "Create BadMail backup to: $BadMail_Backup"
Copy-Item -Recurse -Path $BadMail -Destination $BadMail_Backup

Write-Host "Cleaning BadMail ..."
Remove-Item –path $BadMail\* -Exclude *.bad

Write-Host "Processing *.bad from: $BadMail"

foreach ($f in Get-ChildItem -Path $BadMail -Filter *.bad) {
    $smpt_body = Get-Content -Path $f.FullName -Raw

    $r = $smpt_body -replace "(?smi)From:[^!]+From:", "From:"

    $r | Out-File -FilePath $Pickup\$($f.BaseName) -Encoding ascii

    Remove-Item $f.FullName
}

start-service -Name SMTPSVC