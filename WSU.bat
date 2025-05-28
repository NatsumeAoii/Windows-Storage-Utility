@echo off
title Automatic Check: CHKDSK, SFC, and DISM (With Confirmation)
color 0A

:: Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] This script must be run as Administrator.
    echo [!] Right-click and choose "Run as administrator".
    pause
    exit /b
)

:input_drive
cls
echo ========================================================
echo      WINDOWS STORAGE UTILITY (CHKDSK + SFC + DISM) v0.5
echo ========================================================
echo.
set /p DRIVE_LETTER=Enter the drive letter to check with CHKDSK (e.g., C, D, E): 

:: Convert to uppercase
call set DRIVE_UC=%%DRIVE_LETTER:~0,1%%
for %%A in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if /I "%DRIVE_LETTER%"=="%%A" set DRIVE_UC=%%A
)

set DRIVE=%DRIVE_UC%:

:: Confirm input
:confirm_input
echo.
echo [✓] The drive to be checked is: %DRIVE%
set /p CONFIRM=Is this correct? (Y/N): 

if /I "%CONFIRM%"=="Y" goto start_process
if /I "%CONFIRM%"=="N" goto input_drive

echo [!] Invalid input. Please enter Y or N only.
goto confirm_input

:start_process
:: Run CHKDSK
echo.
echo [1/4] Running CHKDSK on drive %DRIVE% ...
chkdsk %DRIVE% /f /r
echo.
echo [!] If this is the system drive, the process will be scheduled at restart.
pause

:: Run SFC
echo.
echo [2/4] Running SFC (System File Checker)...
sfc /scannow
echo.
echo [✓] SFC scan completed.
pause

:: Run DISM
echo.
echo [3/4] Running DISM - CheckHealth...
DISM /Online /Cleanup-Image /CheckHealth
echo.

echo [4/4] Running DISM - ScanHealth...
DISM /Online /Cleanup-Image /ScanHealth
echo.

echo Running DISM - RestoreHealth...
DISM /Online /Cleanup-Image /RestoreHealth
echo.

echo ==========================================================
echo All processes are complete. It is recommended to restart your PC.
echo Logs can be found at:
echo - SFC  : C:\Windows\Logs\CBS\CBS.log
echo - DISM : C:\Windows\Logs\DISM\dism.log
echo ==========================================================
pause
