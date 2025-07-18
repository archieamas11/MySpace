# Simple Windows App Installation Script
# Personal use - installs essential apps and development environment

#Requires -RunAsAdministrator

Write-Host "Starting installation of essential applications..." -ForegroundColor Green

# Get script directory for file operations
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Function to install winget apps with basic feedback
function Install-App {
    param([string]$AppId, [string]$AppName)
    Write-Host "Installing $AppName..." -ForegroundColor Yellow
    try {
        winget install -e --id $AppId
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $AppName installed successfully" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $AppName installation completed with warnings" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Failed to install $AppName" -ForegroundColor Red
    }
}

# Essential Applications
Install-App "Microsoft.WindowsTerminal" "Windows Terminal"
Install-App "M2Team.NanaZip" "NanaZip"
Install-App "Nilesoft.Shell" "Nilesoft Shell"
Install-App "FxSoundLLC.FxSound" "FxSound"

# Oh My Posh
Write-Host "Installing Oh My Posh..." -ForegroundColor Yellow
try {
    winget install JanDeDobbeleer.OhMyPosh --source winget --scope user --force
    Write-Host "✅ Oh My Posh installed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install Oh My Posh" -ForegroundColor Red
}

# Copy PowerShell profile
$sourceProfile = Join-Path (Split-Path $scriptDir -Parent) "Powershell\Microsoft.PowerShell_profile.ps1"
$destProfile = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$destProfileCore = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

if (Test-Path $sourceProfile) {
    # Windows PowerShell
    $destDir = Split-Path $destProfile -Parent
    if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -Path $sourceProfile -Destination $destProfile -Force
    Write-Host "✅ PowerShell profile copied" -ForegroundColor Green
    
    # PowerShell Core
    $destDirCore = Split-Path $destProfileCore -Parent
    if (!(Test-Path $destDirCore)) { New-Item -ItemType Directory -Path $destDirCore -Force | Out-Null }
    Copy-Item -Path $sourceProfile -Destination $destProfileCore -Force
} else {
    Write-Host "❌ PowerShell profile not found" -ForegroundColor Red
}

# Visual C++ Runtimes download
Write-Host "Downloading Visual C++ Runtimes..." -ForegroundColor Yellow
try {
    $vcUrl = "https://us3-dl.techpowerup.com/files/to6d7rYZ9ziXDvIKZefjYg/1752175249/Visual-C-Runtimes-All-in-One-Jun-2025.zip"
    $vcPath = "$env:USERPROFILE\Downloads\Visual-C-Runtimes-All-in-One-Jun-2025.zip"
    Invoke-WebRequest -Uri $vcUrl -OutFile $vcPath -UseBasicParsing
    Write-Host "✅ Visual C++ Runtimes downloaded" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download Visual C++ Runtimes" -ForegroundColor Red
}

# Development Environment
Install-App "LeNgocKhoa.Laragon" "Laragon"
Install-App "OpenJS.NodeJS" "Node.js"
Install-App "Git.Git" "Git"

# Configure Node.js PATH
Write-Host "Configuring Node.js..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
$nodePath = "$env:ProgramFiles\nodejs"
if (Test-Path $nodePath) {
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$nodePath*") {
        $newPath = "$currentPath;$nodePath"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
        $env:PATH = "$nodePath;$env:PATH"
        Write-Host "✅ Node.js added to PATH" -ForegroundColor Green
    } else {
        Write-Host "✅ Node.js already in PATH" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Node.js not found" -ForegroundColor Red
}

# Configure Git
Write-Host "Configuring Git..." -ForegroundColor Yellow
try {
    git config --global user.name "archieamas11"
    git config --global user.email "archiealbarico69@gmail.com"
    git config --global init.defaultBranch main
    Write-Host "✅ Git configured" -ForegroundColor Green
} catch {
    Write-Host "❌ Git configuration failed" -ForegroundColor Red
}

# Install Composer
Write-Host "Installing Composer..." -ForegroundColor Yellow
if (Get-Command php -ErrorAction SilentlyContinue) {
    try {
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php composer-setup.php
        php -r "unlink('composer-setup.php');"
        Write-Host "✅ Composer installed" -ForegroundColor Green
    } catch {
        Write-Host "❌ Composer installation failed" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  PHP not found, skipping Composer" -ForegroundColor Yellow
}

# Productivity Applications
Install-App "Microsoft.VisualStudioCode" "VS Code"
Install-App "Notepad++.Notepad++" "Notepad++"
Install-App "Klocman.BulkCrapUninstaller" "Bulk Crap Uninstaller"
Install-App "RevoUninstaller.RevoUninstaller" "Revo Uninstaller"
Install-App "voidtools.Everything" "Everything"
Install-App "Microsoft.PowerToys" "PowerToys"
Install-App "rocksdanister.LivelyWallpaper" "Lively Wallpaper"
Install-App "AltSnap.AltSnap" "AltSnap"
Install-App "AutoHotkey.AutoHotkey" "AutoHotkey"
Install-App "BlastApps.FluentSearch" "Fluent Search"
Install-App "localsend" "LocalSend"
Install-App "KDE.KDEConnect" "KDE Connect"
Install-App "Guru3D.Afterburner" "MSI Afterburner"
Install-App "ALCPU.CoreTemp" "Core Temp"
Install-App "SoftDeluxe.FreeDownloadManager" "Free Download Manager"
Install-App "MartiCliment.UniGetUI" "UniGetUI"
Install-App "OBSProject.OBSStudio" "OBS Studio"
Install-App "Flow Launcher" "Flow Launcher"
Install-App "JackieLiu.NotepadsApp" "Notepads"
Install-App "Valve.Steam" "Steam"

# File Customizations
Write-Host "Installing customizations..." -ForegroundColor Yellow

# Notepad++ theme
$sourceTheme = Join-Path $scriptDir "Notepad++\Fluent.xml"
$destTheme = "$env:APPDATA\Notepad++\themes\Fluent.xml"
if (Test-Path $sourceTheme) {
    $destDir = Split-Path $destTheme -Parent
    if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -Path $sourceTheme -Destination $destTheme -Force
    Write-Host "✅ Notepad++ theme installed" -ForegroundColor Green
} else {
    Write-Host "❌ Notepad++ theme not found" -ForegroundColor Red
}

# Notepad++ plugin
$sourcePlugin = Join-Path $scriptDir "Notepad++\DarkNpp"
$destPlugin = "C:\Program Files\Notepad++\plugins\DarkNpp"
if (Test-Path $sourcePlugin) {
    try {
        if (Test-Path $destPlugin) { Remove-Item -Path $destPlugin -Recurse -Force }
        Copy-Item -Path $sourcePlugin -Destination $destPlugin -Recurse -Force
        Write-Host "✅ Notepad++ plugin installed" -ForegroundColor Green
    } catch {
        Write-Host "❌ Notepad++ plugin failed (need admin)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Notepad++ plugin not found" -ForegroundColor Red
}

# QuickLook
$quicklookMsi = Join-Path $scriptDir "Quicklook.msi"
if (Test-Path $quicklookMsi) {
    try {
        Start-Process msiexec.exe -ArgumentList "/i `"$quicklookMsi`" /qn" -Wait
        Write-Host "✅ QuickLook installed" -ForegroundColor Green
    } catch {
        Write-Host "❌ QuickLook installation failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ QuickLook MSI not found" -ForegroundColor Red
}

# Optional Applications
Write-Host "`nOptional applications:" -ForegroundColor Cyan

$choice = Read-Host "Install SeelenUI? [Y/N]"
if ($choice -match '^[Yy]$') {
    Install-App "Seelen.SeelenUI" "SeelenUI"
}

$choice = Read-Host "Install Windhawk? [Y/N]"
if ($choice -match '^[Yy]$') {
    Write-Host "Downloading Windhawk..." -ForegroundColor Yellow
    try {
        $windhawkUrl = "https://objects.githubusercontent.com/github-production-release-asset-2e65be/448262991/8316aa4f-1109-483a-9ce4-993b7207d5d8?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250710%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250710T072723Z&X-Amz-Expires=1800&X-Amz-Signature=a42411604bf0931699a714d08daa24a9ca04349060aba4be3eba49fb35f8c290&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dwindhawk_setup.exe&response-content-type=application%2Foctet-stream"
        $windhawkPath = "$env:USERPROFILE\Downloads\windhawk_setup.exe"
        Invoke-WebRequest -Uri $windhawkUrl -OutFile $windhawkPath -UseBasicParsing
        Start-Process -FilePath $windhawkPath
        Write-Host "✅ Windhawk downloaded and launched" -ForegroundColor Green
    } catch {
        Write-Host "❌ Windhawk download failed" -ForegroundColor Red
    }
}

Write-Host "`nInstallation completed!" -ForegroundColor Green
Write-Host "Restart terminal for PATH changes to take effect." -ForegroundColor Yellow
