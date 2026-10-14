@echo off
title n8n Workflow Automation Engine [Port 5678]
cd /d "%~dp0"

echo ==============================================================================
echo                 N8N LOCAL WORKFLOW AUTOMATION ENGINE
echo ==============================================================================
echo.

:: 1. Enable Node built-in module permissions for full Code node execution
set "NODE_FUNCTION_ALLOW_BUILTIN=*"

:: 2. Verify or Auto-Install Node.js LTS
set "NODE_EXE="
where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "NODE_EXE=node"
) else (
    if exist "%ProgramFiles%\nodejs\node.exe" set "NODE_EXE=%ProgramFiles%\nodejs\node.exe"
    if exist "%ProgramFiles(x86)%\nodejs\node.exe" set "NODE_EXE=%ProgramFiles(x86)%\nodejs\node.exe"
)

if "%NODE_EXE%"=="" (
    echo [!] Node.js not detected. Auto-downloading official Node.js 20 LTS...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi', '$env:TEMP\node-v20.msi')"
    echo [!] Installing Node.js silently (this takes ~1 minute)...
    msiexec /i "%TEMP%\node-v20.msi" /qn /norestart
    set "PATH=%ProgramFiles%\nodejs;%APPDATA%\npm;%PATH%"
    set "NODE_EXE=%ProgramFiles%\nodejs\node.exe"
)

set "PATH=%ProgramFiles%\nodejs;%APPDATA%\npm;%PATH%"

:: 3. Check if n8n is installed
where n8n >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    if not exist "%APPDATA%\npm\n8n.cmd" (
        echo [!] n8n not found on system. Installing globally via npm...
        call npm install -g n8n
    )
)

:: 3. Launch browser to n8n canvas
echo [!] Opening n8n Web Interface...
start "" http://localhost:5678

:: 4. Start n8n engine
echo [!] Starting n8n with unconstrained code sandbox permissions...
if exist "%APPDATA%\npm\node_modules\n8n\bin\n8n" (
    node "%APPDATA%\npm\node_modules\n8n\bin\n8n" start
) else (
    n8n start
)

pause
