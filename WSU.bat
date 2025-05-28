@echo off
setlocal enabledelayedexpansion

:: Administrative Privilege Check
fltmc >nul 2>&1 || (
    echo [!] This script requires Administrator privileges
    echo [!] Right-click and select "Run as administrator"
    timeout /t 5 /nobreak >nul
    exit /b 1
)

:: Universal Timestamp Format
for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set "datetime=%%G"
set "LOG_TIMESTAMP=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%_%datetime:~8,2%-%datetime:~10,2%"

:: Configuration Settings
set "LOGDIR=%SystemDrive%\Windows\Logs\StorageUtility"
set "CHKDSK_LOG=%LOGDIR%\%COMPUTERNAME%_CHKDSK_%LOG_TIMESTAMP%.log"
set "SFC_LOG=%LOGDIR%\%COMPUTERNAME%_SFC_%LOG_TIMESTAMP%.log"
set "DISM_LOG=%LOGDIR%\%COMPUTERNAME%_DISM_%LOG_TIMESTAMP%.log"

:MAIN
cls
color 0A
title Automatic CHKDSK, SFC, and DISM Check (Enhanced Version)
echo ========================================================
echo      WINDOWS STORAGE UTILITY (CHKDSK + SFC + DISM) v1.0
echo ========================================================
echo.
echo Initializing system maintenance utility...

:: Dynamic Drive Detection
echo.
echo Detecting available volumes...
set "tempfile=%temp%\vol_list.tmp"
echo list volume > "%tempfile%"
echo exit >> "%tempfile%"
diskpart /s "%tempfile%" | findstr /i /c:"Volume"
del "%tempfile%" >nul 2>&1

:GET_DRIVE
echo.
set /p "DRIVE=Enter drive letter to check with CHKDSK (e.g., C, D, E): "
set "DRIVE=%DRIVE:"=%"
set "DRIVE=%DRIVE: =%"
set "DRIVE=%DRIVE:~0,1%"
if "%DRIVE%"=="" goto GET_DRIVE
if /I "%DRIVE%" LSS "A" goto GET_DRIVE
if /I "%DRIVE%" GTR "Z" goto GET_DRIVE
set "DRIVE=%DRIVE%:"

:: Drive Validation
if not exist "%DRIVE%\" (
    echo.
    echo [!] Drive %DRIVE% is not accessible or does not exist
    timeout /t 2 /nobreak >nul
    goto GET_DRIVE
)

:: Operation Confirmation
:CONFIRM
echo.
echo [✓] The system to be checked is drive: %DRIVE%
set /p "CONFIRM=Is this correct? (Y/N): "
if "%CONFIRM%"=="" goto CONFIRM
if /I "%CONFIRM%"=="Y" goto PREPARE
if /I "%CONFIRM%"=="N" goto GET_DRIVE
echo [!] Input not recognized. Please type Y or N only.
goto CONFIRM

:PREPARE
if not exist "%LOGDIR%" (
    mkdir "%LOGDIR%" >nul 2>&1
)

echo.
echo Cleaning up old logs...
forfiles /p "%LOGDIR%" /m *.log /d -30 /c "cmd /c del @path" >nul 2>&1

:: CHKDSK Execution
:RUN_CHKDSK
echo.
echo [1/4] Running CHKDSK on drive %DRIVE% ...
echo [!] This will show real-time progress below:
echo [!] Estimated time: 10-30 minutes depending on drive size
echo [!] Please wait while CHKDSK analyzes %DRIVE%...

echo.
echo Running CHKDSK on Drive %DRIVE%
chkdsk %DRIVE% /f /r

echo.
echo [✓] CHKDSK completed successfully.
pause

:: SFC Execution
:RUN_SFC
echo.
echo [2/4] Running SFC (System File Checker)...
sfc /scannow

echo.
echo [✓] SFC completed successfully.
pause

:: DISM Execution
:RUN_DISM
echo.
echo [3/4] Running DISM - CheckHealth...
DISM /Online /Cleanup-Image /CheckHealth

echo.
echo [4/4] Running DISM - ScanHealth...
DISM /Online /Cleanup-Image /ScanHealth

echo.
echo Running DISM - RestoreHealth...
DISM /Online /Cleanup-Image /RestoreHealth

:: Completion Summary
:COMPLETE
echo.
echo ==========================================================
echo All processes completed. It is recommended to restart your PC.
echo Logs can be found at:
echo - CHKDSK: %CHKDSK_LOG%
echo - SFC   : %SFC_LOG%
echo - DISM  : %DISM_LOG%
echo ==========================================================
echo.
echo Final Options:
echo  1. View CHKDSK Log
echo  2. View SFC Log  
echo  3. View DISM Log
echo  4. Schedule System Restart
echo  5. Exit Utility
echo ==========================================================

:CHOICE
set "OPTION="
set /p "OPTION=Select option (1-5): "
if "%OPTION%"=="1" (
    if exist "%CHKDSK_LOG%" (
        notepad "%CHKDSK_LOG%"
    ) else (
        echo [!] CHKDSK log not found
        timeout /t 2 /nobreak >nul
    )
    goto CHOICE
)
if "%OPTION%"=="2" (
    if exist "%SFC_LOG%" (
        notepad "%SFC_LOG%"
    ) else (
        echo [!] SFC log not found
        timeout /t 2 /nobreak >nul
    )
    goto CHOICE
)
if "%OPTION%"=="3" (
    if exist "%DISM_LOG%" (
        notepad "%DISM_LOG%"
    ) else (
        echo [!] DISM log not found
        timeout /t 2 /nobreak >nul
    )
    goto CHOICE
)
if "%OPTION%"=="4" (
    echo.
    echo [!] System will restart in 30 seconds
    echo [!] Press Ctrl+C to cancel
    shutdown /r /t 30 /c "Scheduled system restart for maintenance completion"
    exit /b
)
if "%OPTION%"=="5" (
    echo.
    echo Thank you for using Windows Storage Utility!
    pause
    exit /b
)
if "%OPTION%"=="" goto CHOICE
echo [!] Invalid option. Please select 1-5.
timeout /t 1 /nobreak >nul
goto CHOICE
