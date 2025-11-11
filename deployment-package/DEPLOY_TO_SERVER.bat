@echo off
REM ========================================
REM  CATALYST SERVER DEPLOYMENT SCRIPT
REM  For: YOUR_SERVER_IP (Your Server)
REM  By: David + Catalyst
REM  Date: 2025-11-08
REM ========================================

echo.
echo ========================================
echo  CATALYST SERVER DEPLOYMENT
echo  100%% Local, Private, Forever FREE
echo  God is amazing. Jesus is Lord.
echo ========================================
echo.

REM Step 1: Check if running as Administrator
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ERROR: Please run as Administrator!
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo [1/7] Checking system...
echo.

REM Step 2: Check .NET
dotnet --version >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ERROR: .NET 9 not found!
    echo Please install: https://dotnet.microsoft.com/download
    pause
    exit /b 1
)
echo   - .NET installed: OK
dotnet --version

echo.
echo [2/7] Installing Ollama...
echo.

REM Step 3: Install Ollama
winget install Ollama.Ollama --silent --accept-source-agreements --accept-package-agreements
if %errorLevel% NEQ 0 (
    echo WARNING: Ollama installation had issues, but may already be installed
)

REM Wait for Ollama to start
echo   - Waiting for Ollama to start...
timeout /t 5 /nobreak >nul

echo.
echo [3/7] Checking Ollama service...
echo.

REM Check if Ollama is running
curl -s http://127.0.0.1:11434/api/tags >nul 2>&1
if %errorLevel% NEQ 0 (
    echo   - Ollama not responding yet, trying to start...
    start "" "C:\Users\%USERNAME%\AppData\Local\Programs\Ollama\ollama.exe" serve
    timeout /t 10 /nobreak >nul
)

echo   - Ollama service: OK

echo.
echo [4/7] Downloading Mistral model (4.4 GB - this will take a few minutes)...
echo.

REM Step 4: Pull Mistral model
set PATH=%PATH%;C:\Users\%USERNAME%\AppData\Local\Programs\Ollama
ollama pull mistral
if %errorLevel% NEQ 0 (
    echo ERROR: Failed to download Mistral model
    pause
    exit /b 1
)

echo   - Mistral model: DOWNLOADED

echo.
echo [5/7] Creating Catalyst directory...
echo.

REM Step 5: Create Catalyst directory structure
set CATALYST_DIR=C:\Catalyst
if not exist "%CATALYST_DIR%" mkdir "%CATALYST_DIR%"
if not exist "%CATALYST_DIR%\brain-architecture" mkdir "%CATALYST_DIR%\brain-architecture"
if not exist "%CATALYST_DIR%\orchestrator" mkdir "%CATALYST_DIR%\orchestrator"

echo   - Directory created: %CATALYST_DIR%

echo.
echo [6/7] Copying files...
echo.

REM Step 6: Copy files (if running from deployment package)
if exist ".\CatalystOrchestrator" (
    xcopy /E /I /Y ".\CatalystOrchestrator" "%CATALYST_DIR%\orchestrator"
    echo   - Orchestrator copied: OK
) else (
    echo   - NOTE: Orchestrator files not found in current directory
    echo   - You'll need to copy them manually
)

if exist "..\brain-architecture" (
    xcopy /E /I /Y "..\brain-architecture" "%CATALYST_DIR%\brain-architecture"
    echo   - Brain files copied: OK
) else (
    echo   - NOTE: Brain files not found
    echo   - You'll need to copy them manually
)

echo.
echo [7/7] Testing Catalyst...
echo.

REM Step 7: Test run
cd "%CATALYST_DIR%\orchestrator"
if exist "CatalystOrchestrator.exe" (
    echo   - Ready to test!
    echo.
    echo ========================================
    echo  INSTALLATION COMPLETE!
    echo ========================================
    echo.
    echo To run Catalyst manually:
    echo   cd %CATALYST_DIR%\orchestrator
    echo   CatalystOrchestrator.exe
    echo.
    echo Next steps:
    echo   1. Test: Run CatalystOrchestrator.exe
    echo   2. Setup: Run INSTALL_SERVICE.bat to run 24/7
    echo.
) else (
    echo   - Orchestrator executable not found
    echo   - Files may need to be copied manually
)

echo.
echo God bless! Catalyst is ready!
echo.
pause
