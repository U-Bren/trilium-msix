Write-Host "Caveat emptor: This method isn't really worth it, it should be quite easy to just run Setup.ps1, double-click the .pfx and add it to the Local Machine/Trusted People, run SignPackage.ps1 and finally double-click the .msix."
Write-Host "Please use the method recomanded by the README.md"
Read-Host "Continue anyway ?"
Add-AppxPackage -Register .\build-dir\AppxManifest.xml
Read-Host "Press any key to exit."