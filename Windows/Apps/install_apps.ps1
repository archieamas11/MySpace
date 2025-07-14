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

# Download Visual C++ Runtimes
$vcRuntimesUrl = "https://us3-dl.techpowerup.com/files/to6d7rYZ9ziXDvIKZefjYg/1752175249/Visual-C-Runtimes-All-in-One-Jun-2025.zip"
$vcRuntimesPath = "$env:USERPROFILE\Downloads\Visual-C-Runtimes-All-in-One-Jun-2025.zip"
Write-Host "Downloading Visual C++ Runtimes..."
try {
    Invoke-WebRequest -Uri $vcRuntimesUrl -OutFile $vcRuntimesPath
    Write-Host "Visual C++ Runtimes downloaded to $vcRuntimesPath"
} catch {
    Write-Host "Failed to download Visual C++ Runtimes: $($_.Exception.Message)"
}

# Laragon and Composer
Write-Host "Installing Laragon..."
winget install -e --id LeNgocKhoa.Laragon
Write-Host "Laragon installation finished. Now installing Composer..."

# Check if PHP is available before installing Composer
if (Get-Command php -ErrorAction SilentlyContinue) {
    try {
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        $composerHash = (Invoke-WebRequest -Uri "https://composer.github.io/installer.sig" -UseBasicParsing).Content.Trim()
        $installerHash = (Get-FileHash "composer-setup.php" -Algorithm SHA384).Hash.ToLower()
        if ($composerHash -eq $installerHash) {
            Write-Host "Composer installer verified."
            php composer-setup.php
            php -r "unlink('composer-setup.php');"
            Write-Host "Composer installed."
        } else {
            Write-Host "Composer installer verification failed."
            Remove-Item "composer-setup.php" -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "Failed to install Composer: $($_.Exception.Message)"
    }
} else {
    Write-Host "PHP not found. Skipping Composer installation. Install PHP first, then run Composer installation manually."
}

winget install -e --id OpenJS.NodeJS
# Add Node.js to PATH for current session
$nodePath = "$env:ProgramFiles\nodejs"
if (Test-Path $nodePath) {
    $env:PATH = "$nodePath;$env:PATH"
    Write-Host "Node.js path added to PATH for this session."
} else {
    Write-Host "Node.js installation directory not found at $nodePath."
}

winget install -e --id Git.Git
# Configure Git user information
git config --global user.name "archieamas11"
git config --global user.email "archiealbarico69@gmail.com"

winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Klocman.BulkCrapUninstaller
winget install -e --id rocksdanister.LivelyWallpaper
winget install -e --id AltSnap.AltSnap
winget install -e --id AutoHotkey.AutoHotkey
winget install localsend
winget install -e --id BlastApps.FluentSearch
winget install -e --id KDE.KDEConnect
winget install -e --id Guru3D.Afterburner
winget install -e --id ALCPU.CoreTemp
winget install -e --id Microsoft.PowerToys
winget install -e --id RevoUninstaller.RevoUninstaller
winget install -e --id SoftDeluxe.FreeDownloadManager
winget install --exact --id MartiCliment.UniGetUI --source winget
winget install -e --id Notepad++.Notepad++

# Copy Fluent.xml theme to Notepad++ themes directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sourceTheme = Join-Path $scriptDir "Notepad++\Fluent.xml"
$destThemeDir = "$env:APPDATA\Notepad++\themes"
if (Test-Path $sourceTheme) {
    if (!(Test-Path $destThemeDir)) {
        New-Item -ItemType Directory -Path $destThemeDir -Force | Out-Null
    }
    Copy-Item -Path $sourceTheme -Destination $destThemeDir -Force
    Write-Host "Fluent theme copied to Notepad++ themes directory."
} else {
    Write-Host "Fluent.xml theme not found at $sourceTheme."
}

# Copy DarkNpp folder to Notepad++ plugins directory
$sourcePluginDir = Join-Path $scriptDir "Notepad++\DarkNpp"
$destPluginDir = "C:\Program Files\Notepad++\plugins\DarkNpp"
if (Test-Path $sourcePluginDir) {
    if (Test-Path $destPluginDir) {
        Remove-Item -Path $destPluginDir -Recurse -Force
    }
    Copy-Item -Path $sourcePluginDir -Destination $destPluginDir -Recurse -Force
    Write-Host "DarkNpp plugin copied to Notepad++ plugins directory."
} else {
    Write-Host "DarkNpp plugin folder not found at $sourcePluginDir."
}

# Install QuickLook from MSI in same folder
$quicklookMsi = Join-Path $scriptDir "Quicklook.msi"
if (Test-Path $quicklookMsi) {
    Write-Host "Installing QuickLook from $quicklookMsi..."
    Start-Process msiexec.exe -ArgumentList "/i `"$quicklookMsi`" /qn" -Wait
    Write-Host "QuickLook installation complete."
} else {
    Write-Host "Quicklook.msi not found in $scriptDir."
}

Write-Host "Essential applications installation complete."
Write-Host ""
Write-Host "Checking for optional applications..."

# Optional applications
Install-Optional -AppName "SeleenUI" -InstallCommand "winget install --id Seelen.SeelenUI"
Install-Optional -AppName "Windhawk" -InstallCommand "https://objects.githubusercontent.com/github-production-release-asset-2e65be/448262991/8316aa4f-1109-483a-9ce4-993b7207d5d8?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250710%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250710T072723Z&X-Amz-Expires=1800&X-Amz-Signature=a42411604bf0931699a714d08daa24a9ca04349060aba4be3eba49fb35f8c290&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dwindhawk_setup.exe&response-content-type=application%2Foctet-stream" -InstallType "download"

Write-Host "All installations are complete."
