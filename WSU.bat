@echo off
setlocal enabledelayedexpansion

:: Administrative Check
fltmc >nul 2>&1 || (
    echo [!] Script must be run as Administrator
    echo[&echo[!] Right-click and select "Run as administrator"
    timeout /t 5 /nobreak >nul
    exit /b 1
)

:: Configuration
set "LOGDIR=%SystemDrive%\Windows\Logs\SystemRepair"
set "LOG_TIMESTAMP=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%"
set "CHKDSK_LOG=%LOGDIR%\%COMPUTERNAME%_CHKDSK_%LOG_TIMESTAMP%.log"
set "SFC_LOG=%LOGDIR%\%COMPUTERNAME%_SFC_%LOG_TIMESTAMP%.log"
set "DISM_LOG=%LOGDIR%\%COMPUTERNAME%_DISM_%LOG_TIMESTAMP%.log"

:MAIN
cls
color 0A
echo ========================================================
echo      SYSTEM REPAIR TOOL (CHKDSK + SFC + DISM) v2.1
echo ========================================================
echo[&echo[Checking available drives...
echo[&vol | find "Drive"

:GET_DRIVE
echo[&set /p "DRIVE=Enter drive letter to check (A-Z): "
set "DRIVE=%DRIVE:~0,1%" >nul
set "DRIVE=%DRIVE:"=%"
set "DRIVE=%DRIVE: =%"
if "%DRIVE%"=="" goto GET_DRIVE

:: Validate drive letter
set "DRIVE=%DRIVE%:"
fsutil fsinfo drivetype %DRIVE% | find "Fixed" >nul || (
    echo[&echo[!] Invalid drive or non-fixed disk: %DRIVE%
    timeout /t 2 /nobreak >nul
    goto GET_DRIVE
)

:: Confirmation
:CONFIRM
echo[&set /p "CONFIRM=Confirm check on %DRIVE% drive (Y/N): "
if /I "%CONFIRM%"=="Y" goto PREPARE
if /I "%CONFIRM%"=="N" goto MAIN
goto CONFIRM

:PREPARE
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1
echo[&echo[Initializing system repair...
timeout /t 1 /nobreak >nul

:: CHKDSK Execution
:RUN_CHKDSK
echo[&echo[=== Running CHKDSK on %DRIVE% ===]
echo[!] This may take considerable time depending on disk size
(
    echo ===== CHKDSK Started: %date% %time% =====
    chkdsk %DRIVE% /f /r /x
    echo ===== CHKDSK Completed: %date% %time% =====
    echo Exit Code: !errorlevel!
) > "%CHKDSK_LOG%"

if %errorlevel% neq 0 (
    echo[&echo[!] CHKDSK encountered errors (Code: %errorlevel%)
    echo[!] Check %CHKDSK_LOG% for details
) else (
    echo[✓] CHKDSK completed successfully
)

if /I "%DRIVE%"=="%SystemDrive%:" (
    echo[&echo[!] System drive detected - CHKDSK will run at next reboot
)
timeout /t 2 /nobreak >nul

:: SFC Execution
:RUN_SFC
echo[&echo[=== Running System File Checker ===]
(
    echo ===== SFC Started: %date% %time% =====
    sfc /scannow
    echo ===== SFC Completed: %date% %time% =====
    echo Exit Code: !errorlevel!
) > "%SFC_LOG%"

if %errorlevel% neq 0 (
    echo[&echo[!] SFC found integrity violations (Code: %errorlevel%)
    echo[!] Review %SFC_LOG% for details
) else (
    echo[✓] System files verified successfully
)
timeout /t 2 /nobreak >nul

:: DISM Execution
:RUN_DISM
echo[&echo[=== Running DISM Health Checks ===]
(
    echo ===== DISM CheckHealth: %date% %time% =====
    DISM /Online /Cleanup-Image /CheckHealth
    echo Exit Code: !errorlevel!
    
    echo[&echo ===== DISM ScanHealth: %date% %time% =====
    DISM /Online /Cleanup-Image /ScanHealth
    echo Exit Code: !errorlevel!
    
    echo[&echo ===== DISM RestoreHealth: %date% %time% =====
    DISM /Online /Cleanup-Image /RestoreHealth /Source:repairSource\install.wim /LimitAccess
    echo Exit Code: !errorlevel!
    
    echo ===== DISM Completed: %date% %time% =====
) > "%DISM_LOG%"

if %errorlevel% neq 0 (
    echo[&echo[!] DISM repair encountered issues (Code: %errorlevel%)
    echo[!] Check %DISM_LOG% for details
) else (
    echo[✓] Component store repaired successfully
)

:: Finalization
:COMPLETE
echo[&echo ========================================================
echo[!] SYSTEM REPAIR COMPLETED
echo[!] Logs saved to: %LOGDIR%
echo[&echo[Options:
echo[ 1. View CHKDSK Log
echo[ 2. View SFC Log
echo[ 3. View DISM Log
echo[ 4. Restart Computer
echo[ 5. Exit
echo ========================================================

:CHOICE
set /p "OPTION=Enter choice (1-5): "
if "%OPTION%"=="1" start "" notepad "%CHKDSK_LOG%"
if "%OPTION%"=="2" start "" notepad "%SFC_LOG%"
if "%OPTION%"=="3" start "" notepad "%DISM_LOG%"
if "%OPTION%"=="4" shutdown /r /t 30 /c "System repair completed - restarting"
if "%OPTION%"=="5" exit /b
goto CHOICE
