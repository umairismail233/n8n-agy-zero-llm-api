@echo off
title Antigravity ZeroLLMapi Bridge Server [Port 5000]
cd /d "%~dp0"

echo ==============================================================================
echo           ANTIGRAVITY ZERO-LLM-API BRIDGE FOR LOCAL N8N
echo ==============================================================================
echo [!] Initializing portable runtime environment...

:: 1. Discover or Auto-Install Python
set "PYTHON_EXE="
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "PYTHON_EXE=python"
) else (
    where py >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        set "PYTHON_EXE=py"
    ) else (
        if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
        if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" set "PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
        if exist "%LOCALAPPDATA%\Programs\Python\Python310\python.exe" set "PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python310\python.exe"
        if exist "C:\Python312\python.exe" set "PYTHON_EXE=C:\Python312\python.exe"
        if exist "C:\Python311\python.exe" set "PYTHON_EXE=C:\Python311\python.exe"
        if exist "C:\Python310\python.exe" set "PYTHON_EXE=C:\Python310\python.exe"
    )
)

if "%PYTHON_EXE%"=="" (
    echo [!] Python 3.10+ not detected. Auto-downloading official Python 3.11...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe', '$env:TEMP\python-3.11.9.exe')"
    echo [!] Installing Python...
    "%TEMP%\python-3.11.9.exe" /quiet InstallAllUsers=0 PrependPath=1 Include_pip=1 SimpleInstall=1
    set "PATH=%LOCALAPPDATA%\Programs\Python\Python311;%LOCALAPPDATA%\Programs\Python\Python311\Scripts;%PATH%"
    set "PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
)

:: 2. Setup Virtual Environment
if not exist "venv\Scripts\activate.bat" (
    echo [!] Creating Python virtual environment...
    "%PYTHON_EXE%" -m venv venv
)
call venv\Scripts\activate.bat

:: 3. Install Dependencies
echo [!] Verifying lightweight bridge dependencies...
pip install -r requirements.txt --quiet

:: 4. Add local bin to PATH
set "PATH=%~dp0bin;%PATH%"
set "N8N_PROJECT_DIR=%~dp0"

:: 5. Check if Gemini Pro / Antigravity credentials exist in .env
findstr /i "GEMINI_AUTH_TOKEN= GEMINI_API_KEY=" .env >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ------------------------------------------------------------------------------
    echo [!] FIRST RUN SETUP: Google Gemini Pro Account / Antigravity Pairing
    echo [!] Launching Chrome Onboarding Portal...
    echo ------------------------------------------------------------------------------
    start "" http://127.0.0.1:5000/setup
) else (
    echo [OK] Validated Google Gemini Pro / Antigravity session in local vault.
)

echo.
echo ==============================================================================
echo [READY] Bridge listening on http://127.0.0.1:5000/v1
echo [INFO]  OpenAI-Compatible Model ID: agy-local-engine
echo [INFO]  Keep this window OPEN while running n8n.
echo ==============================================================================
echo.

uvicorn main:app --host 127.0.0.1 --port 5000 --workers 1
pause
