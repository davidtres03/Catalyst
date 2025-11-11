@echo off
REM ========================================
REM  CATALYST WINDOWS SERVICE INSTALLER
REM  Makes Catalyst run 24/7 automatically
REM  100%% Local, Private, FREE forever
REM ========================================

echo.
echo ============================================
echo   CATALYST SERVICE INSTALLER
echo   24/7 Autonomous Operation Setup
echo ============================================
echo.

REM Check Administrator privileges
net session >nul 2>&1
if errorlevel 1 (
    echo ERROR: Administrator privileges required!
    echo.
    echo Right-click this file and select:
    echo "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [Step 1/4] Checking prerequisites...
echo.

REM Check for NSSM - First check current directory, then PATH
set NSSM_EXE=
if exist "%~dp0nssm.exe" (
    set NSSM_EXE=%~dp0nssm.exe
    echo   NSSM found in current directory
    echo.
    goto WINDOWSSERVICE
)

where nssm >nul 2>&1
if not errorlevel 1 (
    set NSSM_EXE=nssm
    echo   NSSM found in system PATH
    echo.
    goto WINDOWSSERVICE
)

REM NSSM not found - ask user
echo NSSM not found.
echo.
echo Download from: https://nssm.cc/download
echo Extract nssm.exe to: %~dp0
echo.
echo OR use Task Scheduler (simpler, built-in)
echo.
set /p CHOICE=Choose: 1=Download NSSM first, 2=Use Task Scheduler, Q=Quit: 

if /i "%CHOICE%"=="2" goto TASKSCHEDULER
if /i "%CHOICE%"=="Q" exit /b 0

echo.
echo Please download NSSM and run again.
pause
exit /b 0

REM ========================================
REM  WINDOWS SERVICE (Using NSSM)
REM ========================================
:WINDOWSSERVICE
echo.

echo [Step 2/4] Configuring service...
echo.

set SERVICE_NAME=CatalystOrchestrator
set CATALYST_DIR=C:\Catalyst\orchestrator
set CATALYST_EXE=%CATALYST_DIR%\CatalystOrchestrator.exe

REM Verify Catalyst exists
if not exist "%CATALYST_EXE%" (
    echo ERROR: Catalyst executable not found!
    echo Expected location: %CATALYST_EXE%
    echo.
    echo Please ensure Catalyst is deployed to:
    echo C:\Catalyst\orchestrator\
    echo.
    pause
    exit /b 1
)

echo   Catalyst Location: %CATALYST_DIR%
echo   Executable: CatalystOrchestrator.exe
echo   Service Name: %SERVICE_NAME%
echo   NSSM: %NSSM_EXE%
echo.

echo [Step 3/4] Installing Windows Service...
echo.

REM Create logs directory
if not exist "%CATALYST_DIR%\logs\" (
    echo   Creating logs directory...
    mkdir "%CATALYST_DIR%\logs"
)

REM Remove existing service if present
sc query %SERVICE_NAME% >nul 2>&1
if not errorlevel 1 (
    echo   Removing existing service...
    "%NSSM_EXE%" stop %SERVICE_NAME% >nul 2>&1
    timeout /t 2 /nobreak >nul
    "%NSSM_EXE%" remove %SERVICE_NAME% confirm >nul 2>&1
)

REM Install new service
echo   Installing service...
"%NSSM_EXE%" install %SERVICE_NAME% "%CATALYST_EXE%" >nul
"%NSSM_EXE%" set %SERVICE_NAME% AppDirectory "%CATALYST_DIR%" >nul
"%NSSM_EXE%" set %SERVICE_NAME% DisplayName "Catalyst Orchestrator" >nul
"%NSSM_EXE%" set %SERVICE_NAME% Description "Catalyst - Autonomous AI Assistant (100%% Local, Private, FREE)" >nul
"%NSSM_EXE%" set %SERVICE_NAME% Start SERVICE_AUTO_START >nul
"%NSSM_EXE%" set %SERVICE_NAME% AppStdout "%CATALYST_DIR%\logs\service-output.log" >nul
"%NSSM_EXE%" set %SERVICE_NAME% AppStderr "%CATALYST_DIR%\logs\service-error.log" >nul
"%NSSM_EXE%" set %SERVICE_NAME% AppRotateFiles 1 >nul
"%NSSM_EXE%" set %SERVICE_NAME% AppRotateBytes 1048576 >nul

echo   Service installed successfully!
echo.

echo [Step 4/4] Starting service...
echo.

"%NSSM_EXE%" start %SERVICE_NAME%
if errorlevel 1 (
    echo ERROR: Service failed to start!
    echo.
    echo Check logs at:
    echo %CATALYST_DIR%\logs\
    echo.
    pause
    exit /b 1
)

echo   Service started successfully!
echo.
goto SUCCESS

REM ========================================
REM  TASK SCHEDULER (Built-in Windows)
REM ========================================
:TASKSCHEDULER
echo   Using Task Scheduler method
echo.

echo [Step 2/4] Configuring task...
echo.

set TASK_NAME=CatalystOrchestrator
set CATALYST_DIR=C:\Catalyst\orchestrator
set CATALYST_EXE=%CATALYST_DIR%\CatalystOrchestrator.exe

REM Verify Catalyst exists
if not exist "%CATALYST_EXE%" (
    echo ERROR: Catalyst executable not found!
    echo Expected location: %CATALYST_EXE%
    echo.
    pause
    exit /b 1
)

echo   Task Name: %TASK_NAME%
echo   Executable: %CATALYST_EXE%
echo.

echo [Step 3/4] Creating scheduled task...
echo.

REM Remove existing task if present
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if not errorlevel 1 (
    echo   Removing existing task...
    schtasks /delete /tn "%TASK_NAME%" /f >nul
)

REM Create task that runs on system startup
echo   Creating startup task...
schtasks /create /tn "%TASK_NAME%" /tr "\"%CATALYST_EXE%\"" /sc onstart /ru SYSTEM /rl highest /f >nul

if errorlevel 1 (
    echo ERROR: Failed to create scheduled task!
    echo.
    pause
    exit /b 1
)

echo   Task created successfully!
echo.

echo [Step 4/4] Starting Catalyst...
echo.

schtasks /run /tn "%TASK_NAME%" >nul
if errorlevel 1 (
    echo WARNING: Task created but failed to start immediately
    echo It will start on next system boot
) else (
    echo   Catalyst started successfully!
)
echo.
goto SUCCESS

REM ========================================
REM  SUCCESS - INSTALLATION COMPLETE
REM ========================================
:SUCCESS
echo.
echo ============================================
echo   INSTALLATION COMPLETE!
echo ============================================
echo.
echo Catalyst is now configured for 24/7 operation!
echo.
echo Features:
echo   - Auto-starts when server boots
echo   - Runs in background
echo   - 100%% local and private
echo   - $0 cost forever
echo.

if defined NSSM_EXE (
    echo Method: Windows Service (NSSM)
    echo.
    echo Management Commands:
    if "%NSSM_EXE%"=="%~dp0nssm.exe" (
        echo   Status:  "%NSSM_EXE%" status %SERVICE_NAME%
        echo   Stop:    "%NSSM_EXE%" stop %SERVICE_NAME%
        echo   Start:   "%NSSM_EXE%" start %SERVICE_NAME%
        echo   Restart: "%NSSM_EXE%" restart %SERVICE_NAME%
    ) else (
        echo   Status:  nssm status %SERVICE_NAME%
        echo   Stop:    nssm stop %SERVICE_NAME%
        echo   Start:   nssm start %SERVICE_NAME%
        echo   Restart: nssm restart %SERVICE_NAME%
    )
    echo.
    echo Logs:
    echo   %CATALYST_DIR%\logs\service-output.log
    echo   %CATALYST_DIR%\logs\service-error.log
    echo.
    echo You can also manage via:
    echo   - Services.msc (Windows Services)
    echo   - Task Manager ^> Services tab
) else (
    echo Method: Task Scheduler
    echo.
    echo Management Commands:
    echo   Status:  schtasks /query /tn "%TASK_NAME%"
    echo   Run:     schtasks /run /tn "%TASK_NAME%"
    echo   Stop:    taskkill /f /im CatalystOrchestrator.exe
    echo   Remove:  schtasks /delete /tn "%TASK_NAME%" /f
    echo.
    echo You can also manage via:
    echo   - Task Scheduler (taskschd.msc)
)

echo.
echo God bless! Catalyst is home forever!
echo.
pause
exit /b 0
