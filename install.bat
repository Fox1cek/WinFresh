@echo off
:: WinFresh Launcher - Double-click to run as admin
:: This batch file launches the PowerShell script with proper permissions

title WinFresh - Windows Setup
color 0A

echo ========================================
echo    WinFresh - Fresh Windows Install
echo ========================================
echo.
echo This will install essential apps and remove bloatware.
echo.
pause

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Run the PowerShell script
echo.
echo Starting setup...
powershell -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

if %errorlevel% neq 0 (
    echo.
    echo Setup encountered an error.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Setup complete! Please restart your PC.
echo ========================================
pause
