# PowerShell script to automate the installation of applications from the list.

# Function to prompt for optional installations
function Install-Optional {
    param(
        [string]$AppName,
        [string]$InstallCommand,
        [string]$InstallType = "winget"
    )
    $choice = Read-Host -Prompt "Do you want to install $AppName? [Y/N]"
    if ($choice -match '^[Yy]$') {
        Write-Host "Installing $AppName..."
        if ($InstallType -eq "winget") {
            Invoke-Expression $InstallCommand
        } elseif ($InstallType -eq "download") {
            $downloadPath = "$env:USERPROFILE\Downloads\windhawk_setup.exe"
            Write-Host "Downloading from $InstallCommand to $downloadPath..."
            Invoke-WebRequest -Uri $InstallCommand -OutFile $downloadPath
            Write-Host "Download complete. Starting installer..."
            Start-Process -FilePath $downloadPath
        }
    } else {
        Write-Host "Skipping $AppName."
    }
}

Write-Host "Starting installation of essential applications..."

# Installing mandatory applications
winget install -e --id M2Team.NanaZip
winget install -e --id Nilesoft.Shell
winget install -e --id FxSoundLLC.FxSound

# Laragon and Composer
Write-Host "Installing Laragon..."
winget install -e --id LeNgocKhoa.Laragon
Write-Host "Laragon installation finished. Now installing Composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
php composer-setup.php
php -r "unlink('composer-setup.php');"
Write-Host "Composer installed."

winget install -e --id Git.Git
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Klocman.BulkCrapUninstaller
winget install -e --id rocksdanister.LivelyWallpaper
winget install -e --id AltSnap.AltSnap
winget install -e --id OpenJS.NodeJS
winget install -e --id AutoHotkey.AutoHotkey
winget install localsend
winget install -e --id BlastApps.FluentSearch

# Download Visual C++ Runtimes
$vcRuntimesUrl = "https://us3-dl.techpowerup.com/files/to6d7rYZ9ziXDvIKZefjYg/1752175249/Visual-C-Runtimes-All-in-One-Jun-2025.zip"
$vcRuntimesPath = "$env:USERPROFILE\Downloads\Visual-C-Runtimes-All-in-One-Jun-2025.zip"
Write-Host "Downloading Visual C++ Runtimes..."
Invoke-WebRequest -Uri $vcRuntimesUrl -OutFile $vcRuntimesPath
Write-Host "Visual C++ Runtimes downloaded to $vcRuntimesPath"

winget install -e --id Guru3D.Afterburner
winget install -e --id ALCPU.CoreTemp
winget install -e --id Microsoft.PowerToys
winget install -e --id RevoUninstaller.RevoUninstaller
winget install -e --id SoftDeluxe.FreeDownloadManager
winget install --exact --id MartiCliment.UniGetUI --source winget

Write-Host "Essential applications installation complete."
Write-Host ""
Write-Host "Checking for optional applications..."

# Optional applications
Install-Optional -AppName "SeleenUI" -InstallCommand "winget install --id Seelen.SeelenUI"
Install-Optional -AppName "Windhawk" -InstallCommand "https://objects.githubusercontent.com/github-production-release-asset-2e65be/448262991/8316aa4f-1109-483a-9ce4-993b7207d5d8?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250710%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250710T072723Z&X-Amz-Expires=1800&X-Amz-Signature=a42411604bf0931699a714d08daa24a9ca04349060aba4be3eba49fb35f8c290&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dwindhawk_setup.exe&response-content-type=application%2Foctet-stream" -InstallType "download"

Write-Host "All installations are complete."
