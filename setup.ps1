#Requires -RunAsAdministrator
<#
.SYNOPSIS
    WinFresh - One-click Windows setup after fresh install
.DESCRIPTION
    Installs essential apps using winget, removes bloatware, configures settings
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File setup.ps1
#>

$ErrorActionPreference = "Stop"

# Colors for output
$Green = "`e[32m"
$Yellow = "`e[33m"
$Red = "`e[31m"
$Reset = "`e[0m"

function Write-Status($Message, $Type = "Info") {
    $icon = switch ($Type) {
        "Success" { "$Green[✓]$Reset" }
        "Warning" { "$Yellow[!]$Reset" }
        "Error"   { "$Red[✗]$Reset" }
        default   { "$Yellow[>]$Reset" }
    }
    Write-Host "$icon $Message"
}

# Check Windows version
$winVer = [System.Environment]::OSVersion.Version
if ($winVer.Major -lt 10) {
    Write-Status "Windows 10/11 required" "Error"
    exit 1
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "   WinFresh - Fresh Windows Setup" -ForegroundColor Cyan
Write-Host "==========================================`n" -ForegroundColor Cyan

# Install winget if missing
Write-Status "Checking winget..."
$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Write-Status "Installing App Installer (winget)..." "Warning"
    $url = "https://aka.ms/getwinget"
    $output = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
    Add-AppxPackage -Path $output
    Remove-Item $output
    Write-Status "Winget installed" "Success"
} else {
    Write-Status "Winget already installed" "Success"
}

# Essential apps people install first
$apps = @(
    @{ Name = "Google Chrome"; Id = "Google.Chrome" },
    @{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode" },
    @{ Name = "7-Zip"; Id = "7zip.7zip" },
    @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC" },
    @{ Name = "Discord"; Id = "Discord.Discord" },
    @{ Name = "Spotify"; Id = "Spotify.Spotify" },
    @{ Name = "Git"; Id = "Git.Git" },
    @{ Name = "Node.js"; Id = "OpenJS.NodeJS" },
    @{ Name = "PowerToys"; Id = "Microsoft.PowerToys" },
    @{ Name = "Notepad++"; Id = "Notepad++.Notepad++" },
    @{ Name = "ShareX"; Id = "ShareX.ShareX" },
    @{ Name = "Steam"; Id = "Valve.Steam" },
    @{ Name = "Microsoft Powertoys"; Id = "Microsoft.PowerToys" }
)

Write-Host "`n--- Installing Apps ---" -ForegroundColor Cyan

$installed = 0
$failed = 0

foreach ($app in $apps) {
    Write-Status "Installing $($app.Name)..."
    try {
        $result = winget install --id $app.Id --accept-source-agreements --accept-package-agreements --silent 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "$($app.Name) installed" "Success"
            $installed++
        } else {
            if ($result -match "already installed" -or $result -match "Found an existing") {
                Write-Status "$($app.Name) already installed" "Success"
                $installed++
            } else {
                Write-Status "Failed to install $($app.Name)" "Error"
                $failed++
            }
        }
    } catch {
        Write-Status "Error installing $($app.Name): $_" "Error"
        $failed++
    }
}

# Remove common bloatware
Write-Host "`n--- Removing Bloatware ---" -ForegroundColor Cyan

$bloatware = @(
    "Microsoft.Windows.Pinball",
    "Microsoft.Windows.Solitaire",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.People",
    "Microsoft.WindowsMaps",
    "Microsoft.3DBuilder",
    "Microsoft.Getstarted",
    "Microsoft.Office.OneNote",
    "Microsoft.SkypeApp",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

foreach ($pkg in $bloatware) {
    try {
        Get-AppxPackage -Name $pkg -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        Write-Status "Removed $pkg" "Success"
    } catch {
        # Ignore errors for bloatware removal
    }
}

# Privacy tweaks
Write-Host "`n--- Privacy Settings ---" -ForegroundColor Cyan

Write-Status "Disabling telemetry..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue

Write-Status "Disabling Cortana..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -ErrorAction SilentlyContinue

Write-Status "Disabling ads in Start menu..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0 -ErrorAction SilentlyContinue

# Enable dark mode
Write-Status "Enabling dark mode..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -ErrorAction SilentlyContinue

# Show file extensions
Write-Status "Showing file extensions..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -ErrorAction SilentlyContinue

# Restart explorer to apply changes
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer

Write-Host "`n==========================================" -ForegroundColor Green
Write-Status "Setup complete! Installed: $installed, Failed: $failed" "Success"
Write-Host "Restart recommended to complete setup" -ForegroundColor Yellow
Write-Host "==========================================`n" -ForegroundColor Green

Write-Host "Installed apps:" -ForegroundColor Cyan
$apps | ForEach-Object { Write-Host "  • $($_.Name)" }
