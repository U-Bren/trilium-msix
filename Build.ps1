Set-Alias -Name makeappx -Value 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe'
Set-Alias -Name signtool -Value 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\SignTool.exe'

function Get-LatestRelease {
    # This code is based on https://gist.github.com/Splaxi/fe168eaa91eb8fb8d62eba21736dc88a.
    # TODO: Find a way of using curl to speedup download.

    $repo = "zadam/trilium"
    $filenamePattern = "trilium-windows-x64-*.zip"
    $pathExtract = "./build-dir/"
    $clearDirectory = Join-Path -Path "$pathExtract" -ChildPath "trilium-windows-x64"
    $innerDirectory = $false
    $preRelease = $false
    $ProgressPreference = 'SilentlyContinue' # Fix for slow download due to printing in the progress bar EVERY. SINGLE. BYTE. received.

    if ($preRelease) {
        $releasesUri = "https://api.github.com/repos/$repo/releases"
        $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri)[0].assets | Where-Object name -like $filenamePattern ).browser_download_url
    }
    else {
        $releasesUri = "https://api.github.com/repos/$repo/releases/latest"
        $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -like $filenamePattern ).browser_download_url
    }

    $pathZip = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $(Split-Path -Path $downloadUri -Leaf)

    #curl.exe -L "$downloadUri" -O "$pathZip"
    Invoke-WebRequest -Uri $downloadUri -Out $pathZip

    Remove-Item -Path $clearDirectory -Recurse -Force -ErrorAction SilentlyContinue

    if ($innerDirectory) {
        $tempExtract = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $((New-Guid).Guid)
        Expand-Archive -Path $pathZip -DestinationPath $tempExtract -Force
        Move-Item -Path "$tempExtract\*" -Destination $pathExtract -Force
        #Move-Item -Path "$tempExtract\*\*" -Destination $location -Force
        Remove-Item -Path $tempExtract -Force -Recurse -ErrorAction SilentlyContinue
    }
    else {
        Expand-Archive -Path $pathZip -DestinationPath $pathExtract -Force
    }

    Remove-Item $pathZip -Force
}

function New-Package {
    makeappx pack /d '.\build-dir\' /p 'Zadam.Trilium.msix'   
}

function Sign-Package {
    $certPath = '.\private\U_Bren-windows-packaging-selfsign.pfx'
    $password = Read-Host -Prompt "Enter the certificate's password"
    Clear-Host #FIXME: Find a better solution (-asProtectedString to String convertion)
    signtool sign /fd SHA256 /td SHA256 /f "$certPath" /p "$password" "./Zadam.Trilium.msix"
    
}

Get-LatestRelease

Write-Host 'If not already done, please bump the version in the manifest and then press Enter'
Read-Host
Write-Host "Generating the package..."

New-Package

Write-Host "Attempting to sign the package."
try {
    Sign-Package
} catch {
    Write-Error "Cannot sign the package. Please run Setup.ps1 before running this script."
    Write-Error "If you plan on using Register.ps1 for installation, this error is expected."
}