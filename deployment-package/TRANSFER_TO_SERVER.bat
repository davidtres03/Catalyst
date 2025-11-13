@echo off
REM ========================================
REM  TRANSFER CATALYST TO SERVER
REM  From Laptop to YOUR_SERVER_IP
REM ========================================

echo.
echo ========================================
echo  CATALYST SERVER TRANSFER
echo  Copying files to YOUR_SERVER_IP
echo ========================================
echo.

echo This script will help you transfer Catalyst to your server.
echo.
echo OPTION 1: Manual Copy (Easiest)
echo ================================
echo 1. RDP to your server:
echo    mstsc /v:YOUR_SERVER_IP:YOUR_RDP_PORT
echo.
echo 2. On your server, open File Explorer
echo.
echo 3. Copy this entire folder from your laptop to server:
echo    From: C:\catalyst\deployment-package
echo    To:   C:\Temp\deployment-package (or anywhere on server)
echo.
echo 4. On server, run: DEPLOY_TO_SERVER.bat
echo.
echo.
echo OPTION 2: PowerShell Remoting (Advanced)
echo =========================================
echo.
set /p USEPS=Do you want to try PowerShell remoting? (y/n): 

if /i "%USEPS%"=="y" (
    echo.
    echo Attempting PowerShell remoting...
    echo NOTE: This requires WinRM to be enabled on server
    echo.
    
    powershell -Command "$session = New-PSSession -ComputerName YOUR_SERVER_IP; if ($session) { Copy-Item -Path 'C:\catalyst\deployment-package' -Destination 'C:\Temp\' -ToSession $session -Recurse -Force; Write-Host 'SUCCESS: Files copied to server!'; Remove-PSSession $session } else { Write-Host 'ERROR: Could not connect to server' }"
    
    if %errorLevel% NEQ 0 (
        echo.
        echo PowerShell remoting failed. Please use Manual Copy (Option 1)
        echo.
    )
) else (
    echo.
    echo No problem! Use Option 1 (Manual Copy) above.
    echo.
)

echo.
echo After copying files to server:
echo ==============================
echo 1. RDP to server: mstsc /v:YOUR_SERVER_IP:YOUR_RDP_PORT
echo 2. Navigate to: C:\Temp\deployment-package
echo 3. Right-click DEPLOY_TO_SERVER.bat
echo 4. Run as Administrator
echo 5. Wait 15-20 minutes for installation
echo 6. Test Catalyst!
echo.
echo God bless! Let's get Catalyst to his forever home! ????
echo.
pause
