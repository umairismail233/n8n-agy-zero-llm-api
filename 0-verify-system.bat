@echo off
title Antigravity System Verifier & Dependency Installer
cd /d "%~dp0"

echo ==============================================================================
echo        ANTIGRAVITY & N8N AUTOMATIC SYSTEM & PREREQUISITE VERIFIER
echo ==============================================================================
echo This script checks and automatically installs:
echo  1. Python 3.10+ (for Local Bridge)
echo  2. Node.js LTS (for Local n8n Engine)
echo  3. n8n Global Package
echo  4. Python Bridge Dependencies
echo ==============================================================================
echo.

:: 1. CHECK PYTHON
echo [1/4] Checking Python 3.10+...
set "PYTHON_CMD="

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "PYTHON_CMD=python"
) else (
    where py >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        set "PYTHON_CMD=py"
    ) else (
        if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
        if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
        if exist "%LOCALAPPDATA%\Programs\Python\Python310\python.exe" set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python310\python.exe"
        if exist "C:\Python312\python.exe" set "PYTHON_CMD=C:\Python312\python.exe"
        if exist "C:\Python311\python.exe" set "PYTHON_CMD=C:\Python311\python.exe"
        if exist "C:\Python310\python.exe" set "PYTHON_CMD=C:\Python310\python.exe"
    )
)

if "%PYTHON_CMD%"=="" (
    echo [!] Python not detected. Downloading official Python 3.11 installer...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Write-Host 'Downloading Python 3.11.9...'; (New-Object Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe', '$env:TEMP\python-3.11.9.exe')"
    echo [!] Installing Python silently...
    "%TEMP%\python-3.11.9.exe" /quiet InstallAllUsers=0 PrependPath=1 Include_pip=1 SimpleInstall=1
    set "PATH=%LOCALAPPDATA%\Programs\Python\Python311;%LOCALAPPDATA%\Programs\Python\Python311\Scripts;%PATH%"
    set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    echo [OK] Python installed successfully.
) else (
    echo [OK] Python is available: %PYTHON_CMD%
)

:: 2. CHECK NODE.JS
echo.
echo [2/4] Checking Node.js LTS...
set "NODE_CMD="

where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "NODE_CMD=node"
) else (
    if exist "%ProgramFiles%\nodejs\node.exe" set "NODE_CMD=%ProgramFiles%\nodejs\node.exe"
    if exist "%ProgramFiles(x86)%\nodejs\node.exe" set "NODE_CMD=%ProgramFiles(x86)%\nodejs\node.exe"
)

if "%NODE_CMD%"=="" (
    echo [!] Node.js not detected. Downloading official Node.js LTS installer...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Write-Host 'Downloading Node.js 20 LTS...'; (New-Object Net.WebClient).DownloadFile('https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi', '$env:TEMP\node-v20.msi')"
    echo [!] Installing Node.js silently (this may take 1-2 minutes)...
    msiexec /i "%TEMP%\node-v20.msi" /qn /norestart
    set "PATH=%ProgramFiles%\nodejs;%APPDATA%\npm;%PATH%"
    set "NODE_CMD=%ProgramFiles%\nodejs\node.exe"
    echo [OK] Node.js installed successfully.
) else (
    echo [OK] Node.js is available: %NODE_CMD%
)

:: Ensure npm is in PATH
set "PATH=%ProgramFiles%\nodejs;%APPDATA%\npm;%PATH%"

:: 3. CHECK N8N
echo.
echo [3/4] Checking n8n automation engine...
where n8n >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    if not exist "%APPDATA%\npm\n8n.cmd" (
        echo [!] n8n not found. Installing globally via npm (this will download n8n engine)...
        call npm install -g n8n --quiet
        echo [OK] n8n installed globally.
    ) else (
        echo [OK] n8n found in %APPDATA%\npm
    )
) else (
    echo [OK] n8n is available globally.
)

:: 4. SETUP VIRTUAL ENVIRONMENT & BRIDGE DEPENDENCIES
echo.
echo [4/4] Setting up Python virtual environment and bridge packages...
if not exist "venv\Scripts\activate.bat" (
    "%PYTHON_CMD%" -m venv venv
)
call venv\Scripts\activate.bat
pip install -r requirements.txt --quiet
echo [OK] Bridge dependencies verified.

echo.
echo ==============================================================================
echo [SUCCESS] ALL SYSTEM PREREQUISITES VERIFIED & READY!
echo ==============================================================================
echo Next steps:
echo  1. Run '1-start-bridge.bat' to start the local AI bridge on port 5000.
echo  2. Run '2-start-n8n.bat' to open n8n on port 5678.
echo ==============================================================================
echo.
pause
