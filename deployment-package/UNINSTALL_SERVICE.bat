@echo off
REM ========================================
REM  CATALYST SERVICE UNINSTALLER
REM  Removes Catalyst Windows Service
REM ========================================

echo.
echo ========================================
echo  CATALYST SERVICE UNINSTALLER
echo ========================================
echo.

REM Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ERROR: This script must be run as Administrator!
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

set SERVICE_NAME=CatalystOrchestrator
set TASK_NAME=CatalystOrchestrator

echo WARNING: This will remove Catalyst from automatic startup.
echo Catalyst will still be installed, but won't run automatically.
echo.
set /p CONFIRM=Are you sure you want to continue? (y/n): 

if /i not "%CONFIRM%"=="y" (
    echo.
    echo Uninstall cancelled.
    pause
    exit /b 0
)

echo.
echo Removing Catalyst service/task...
echo.

REM Try NSSM service first
where nssm >nul 2>&1
if %errorLevel% EQU 0 (
    sc query %SERVICE_NAME% >nul 2>&1
    if %errorLevel% EQU 0 (
        echo Stopping Windows Service...
        nssm stop %SERVICE_NAME%
        timeout /t 3 /nobreak >nul
        
        echo Removing Windows Service...
        nssm remove %SERVICE_NAME% confirm
        
        if %errorLevel% EQU 0 (
            echo   - Service removed successfully
        ) else (
            echo   - Warning: Service removal had issues
        )
    )
)

REM Try Task Scheduler
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% EQU 0 (
    echo Removing scheduled task...
    schtasks /delete /tn "%TASK_NAME%" /f
    
    if %errorLevel% EQU 0 (
        echo   - Task removed successfully
    ) else (
        echo   - Warning: Task removal had issues
    )
)

REM Stop any running instances
tasklist /fi "imagename eq CatalystOrchestrator.exe" | find /i "CatalystOrchestrator.exe" >nul
if %errorLevel% EQU 0 (
    echo Stopping running Catalyst processes...
    taskkill /f /im CatalystOrchestrator.exe >nul 2>&1
    echo   - Processes stopped
)

echo.
echo ========================================
echo  UNINSTALL COMPLETE
echo ========================================
echo.
echo Catalyst service/task has been removed.
echo.
echo The files are still in C:\Catalyst\
echo To run Catalyst manually:
echo   cd C:\Catalyst\orchestrator
echo   CatalystOrchestrator.exe
echo.
echo To reinstall as service:
echo   Run INSTALL_SERVICE.bat
echo.
pause
