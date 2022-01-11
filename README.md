# Trilium-appx - Package [Trilium](https://github.com/zadam/trilium) as an MSIX/Appx
The goal of this repo is to provide a easy way of installing Trilium using a .msix.

This allows for trilium to be installed in a protected location (ie. out of my view), and for it to appear and be managed as any other program in the Settings.

PRs warmly welcomed.

## TL;DR: How to install the lazy way:
- Download the [latest package available in the release page](https://github.com/U-Bren/trilium-msix/releases/latest).
- Install [App installer from the Microsoft Store](https://www.microsoft.com/fr-fr/p/app-installer/9nblggh4nns1)
- Right-click on the downloaded .msix -> Properties -> Digital Signatures -> Select the first entry -> Details -> Show certificate -> Install a certificate -> Current Machine -> Select the following store: Trusted People.
  - This only needs to be done once per year (on the next update after the certificate validity will have expired)
  - This is needed for the App installer to install the application, as otherwise it will refuse as the application is untrusted.
  - Open the .msix using App installer.


## Dependencies
### Installation dependencies
- App Installer
  - [Available in the Windows Store](https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1).
### Build dependencies
- ``makeappx.exe`` and ``signtool.exe``
  -  Assumed by the scripts in this repo to be at ``C:\Program Files (x86)\Windows Kits\10\App Certification Kit\``.
  - Part of the [Windows SDK, available here](https://developer.microsoft.com/fr-fr/windows/downloads/windows-sdk/)
  - The downloaded file is big, but unfortunately AFAIK those two tools aren't available in a standalone form. However you can deselect everything except the App Certification Kit during the Windows SDK install itself. 

## How to install/update

### The right way: using the generated .msix and App Installer

#### **(Only on first install): Setup the self-signed certificate**
This require a bit of setup on the first installation (and every year after that by default).
- Generate a self-signed certificate using ``Setup.ps1``.
  - You'll probably like editing the script so that the generated certificate matches your name, but nothing bad will happen either way.
  - Open the generated .pfx using the explorer, then **install the certificate to the CurrentMachine/TrustedPeople store**.
    - This is needed for the App installer to install the application, as otherwise it will refuse as the application is untrusted.

#### Sign the package
- Run the ``SignPackage.ps1`` script and enter the certificate's password.
  - I personally like to store the .pfx as well as the certificate's password in KeepassXC.

#### Install the .msix itself
Once the .msix is signed and provided that the certificate is trusted, you can simply right-click it to open the App installer.


### The dirty way: Manually registering the AppxManifest
**Please note that this method register directly the AppxManifest.xml file (NOT the .msix).**

The main effect is that trilium is installed inside of the build-dir, instead of being copied to a protected location like regular UWP (.appx or .msix). For this reason, deleting the build-dir breaks your trilium installation.
However, your data is still stored in ``%appdata%/trilium-data`` (as with any "normal" trilium install).

1. (If upgrading): Close all running instances of trilium.
2. Run ``Register.ps1``

## How to build/package a new version
- Edit the Version attribute in ``build-dir/AppxManifest.xml`` to match the latest release version (not pre-release) of Trilium.
- Run ``Build.ps1``. This will:
  - Download the latest release of Trilium from github
  - Generate the package 
- Edit the Version attribute in ``build-dir/AppxManifest.xml`` to match the latest release version (not pre-release) of Trilium.
  - The correct version number can be found by right-clicking on ``build-dir/trilium-windows-x64/trilium.exe`` -> Details -> Version.
  - This is annoying and should be automated (PRs welcome).
