# This script will create a new self signed certificate,
# add it to the CurrentUser\My certificate store
# and export it to $certPath
# It is expected for the generated .pfx to be added to the CurrentMachine/TrustedPeople certificate store

Write-Host "This script will create a new self signed certificate."
$certSubject = "CN=U_Bren, OU=Packaging"
$certFriendlyName = "U_Bren Packaging cert"
$certPath = "./private/U_Bren-windows-packaging-selfsign.pfx"

$password = Read-Host -Prompt "Enter password for the new certificate (do not use any special characters)" -AsSecureString

New-SelfSignedCertificate -Type Custom -Subject "$certSubject" -KeyUsage DigitalSignature -FriendlyName "$certFriendlyName" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}") | Export-PfxCertificate -FilePath "$certPath" -Password $password $certificate

Write-Host "It is expected for the generated .pfx to be added to the CurrentMachine/TrustedPeople (NOT CurrentUser) certificate store."
Write-Host "It can be done simply by opening the $certPath using the explorer."
Read-Host -Prompt "Press any key to exit."