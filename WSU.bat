@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: WINDOWS STORAGE UTILITY (CHKDSK + SFC + DISM) v2.0
:: Description: Automates system health checks, with robust logging and error handling.
:: ============================================================================


:: ----------------------------------------------------------------------------
:: Configuration Settings
:: ----------------------------------------------------------------------------
set "LOG_PARENT_DIR=%SystemDrive%\Windows\Logs"
set "LOG_DIR_NAME=StorageUtility"
set "LOG_DIR=%LOG_PARENT_DIR%\%LOG_DIR_NAME%"
set "OLD_LOG_CLEANUP_DAYS=30"


:: ----------------------------------------------------------------------------
:: Initialization and Checks
:: ----------------------------------------------------------------------------

:: Administrative Privilege Check
fltmc >nul 2>&1 || (
    echo [ERROR] This script requires Administrator privileges to function correctly.
    echo [INFO]  Please right-click the script and select "Run as administrator".
    timeout /t 7 /nobreak >nul
    exit /b 1
)

:: Universal Timestamp for unique log file names
for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set "dt=%%G"
set "TIMESTAMP=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%h%dt:~10,2%m"

:: Define Log File Paths
set "CHKDSK_LOG=%LOG_DIR%\%COMPUTERNAME%_CHKDSK_%TIMESTAMP%.log"
set "SFC_LOG=%LOG_DIR%\%COMPUTERNAME%_SFC_%TIMESTAMP%.log"
set "DISM_LOG=%LOG_DIR%\%COMPUTERNAME%_DISM_%TIMESTAMP%.log"

:: Global flags
set "REBOOT_NEEDED=0"


:: ----------------------------------------------------------------------------
:: Main Script Logic
:: ----------------------------------------------------------------------------
:MAIN
call :_display_header
call :_prepare_logging
call :_get_target_drive
if "%DRIVE%"=="" (
    echo [ERROR] No drive was selected. Exiting.
    goto :END_SCRIPT
)

call :_run_chkdsk
call :_run_sfc
call :_run_dism
call :_show_summary

goto :END_SCRIPT


:: ============================================================================
:: SUBROUTINES / FUNCTIONS
:: ============================================================================

:_display_header
    cls
    color 0A
    title Automatic CHKDSK, SFC, and DISM Utility v2.0
    echo ========================================================
    echo    WINDOWS STORAGE UTILITY (CHKDSK + SFC + DISM) v2.0
    echo ========================================================
    echo.
    echo [INFO] Initializing system maintenance utility...
    echo [INFO] Logs will be saved in: %LOG_DIR%
goto :eof


:_prepare_logging
    if not exist "%LOG_DIR%" (
        echo [INFO] Creating log directory...
        mkdir "%LOG_DIR%" >nul 2>&1
        if !errorlevel! neq 0 (
            echo [ERROR] Could not create log directory: %LOG_DIR%.
            echo [INFO]  Please check permissions. Exiting.
            timeout /t 5 >nul
            exit /b 1
        )
    )

    echo [INFO] Cleaning up logs older than %OLD_LOG_CLEANUP_DAYS% days...
    forfiles /p "%LOG_DIR%" /m *.log /d -%OLD_LOG_CLEANUP_DAYS% /c "cmd /c del @path" >nul 2>&1
goto :eof


:_get_target_drive
    echo.
    echo [INFO] Detecting available volumes...
    set "tempfile=%temp%\vol_list.tmp"
    (
        echo list volume
        echo exit
    ) > "%tempfile%"
    diskpart /s "%tempfile%" | findstr /i /c:"Volume"
    del "%tempfile%" >nul 2>&1

    :GET_DRIVE_LOOP
    echo.
    set "DRIVE_LETTER="
    set /p "DRIVE_LETTER=Enter drive letter for CHKDSK (e.g., C): "
    
    :: Sanitize input
    set "DRIVE_LETTER=%DRIVE_LETTER:"=%"
    set "DRIVE_LETTER=%DRIVE_LETTER: =%"
    set "DRIVE_LETTER=%DRIVE_LETTER:~0,1%"
    
    if not defined DRIVE_LETTER goto GET_DRIVE_LOOP
    
    set "DRIVE=%DRIVE_LETTER%:"
    
    :: Validate drive exists
    if not exist "%DRIVE%\" (
        echo [WARN] Drive %DRIVE% is not accessible or does not exist. Please try again.
        goto GET_DRIVE_LOOP
    )

    :CONFIRM_DRIVE
    echo.
    set /p "CONFIRM=[CONFIRM] You have selected drive %DRIVE% for CHKDSK. Is this correct? (Y/N): "
    if /I "%CONFIRM%"=="Y" goto :eof
    if /I "%CONFIRM%"=="N" (
        set "DRIVE="
        goto GET_DRIVE_LOOP
    )
    echo [WARN] Invalid input. Please enter Y or N.
    goto CONFIRM_DRIVE
goto :eof


:_run_chkdsk
    echo.
    echo --------------------------------------------------------
    echo [1/3] EXECUTING CHKDSK ON DRIVE %DRIVE%
    echo --------------------------------------------------------
    echo [INFO] Logging CHKDSK output to: %CHKDSK_LOG%
    
    :: Check if the target is the system drive, as CHKDSK /F /R will require a reboot
    if /I "%DRIVE%"=="%SystemDrive%" (
        echo [WARN] The target drive %DRIVE% is the System Drive.
        echo [WARN] CHKDSK will schedule a scan to run on the next system restart.
        set "REBOOT_NEEDED=1"
    ) else (
        echo [INFO] This may take a long time depending on drive size and health.
    )
    echo.

    (
        echo ========================================================
        echo  CHKDSK Log for %DRIVE% on %DATE% at %TIME%
        echo ========================================================
    ) > "%CHKDSK_LOG%"

    chkdsk %DRIVE% /f /r | cmd /c "for /f "delims=" %%a in ('more') do (echo %%a & echo %%a >> ""%CHKDSK_LOG%"" )"
    
    if !errorlevel! equ 0 (
        echo [SUCCESS] CHKDSK completed or was scheduled successfully.
    ) else (
        echo [ERROR] CHKDSK reported errors. Check the log for details.
    )
    pause
goto :eof


:_run_sfc
    echo.
    echo --------------------------------------------------------
    echo [2/3] EXECUTING SYSTEM FILE CHECKER (SFC)
    echo --------------------------------------------------------
    echo [INFO] Logging SFC output to: %SFC_LOG%
    echo [INFO] This scan may take 5-15 minutes. Please wait.
    echo.
    
    sfc /scannow | cmd /c "for /f "delims=" %%a in ('more') do (echo %%a)"

    if !errorlevel! equ 0 (
        echo [SUCCESS] SFC did not find any integrity violations.
    ) else (
        echo [WARN] SFC found and repaired corrupt files. A reboot is recommended.
        echo [WARN] See CBS.log for details. A filtered log will be created.
        set "REBOOT_NEEDED=1"
    )

    echo [INFO] Creating a clean, filtered SFC log from CBS.log...
    findstr /c:"[SR]" "%windir%\Logs\CBS\CBS.log" > "%SFC_LOG%"
    if !errorlevel! equ 0 (
        echo [SUCCESS] Filtered SFC log created successfully.
    ) else (
        echo [ERROR] Could not create filtered SFC log. You may need to check CBS.log manually.
    )
    pause
goto :eof


:_run_dism
    echo.
    echo --------------------------------------------------------
    echo [3/3] EXECUTING DEPLOYMENT IMAGING AND SERVICING (DISM)
    echo --------------------------------------------------------
    echo [INFO] Logging DISM output to: %DISM_LOG%
    
    (
        echo ========================================================
        echo  DISM Log on %DATE% at %TIME%
        echo ========================================================
    ) > "%DISM_LOG%"

    :: Step 1: CheckHealth
    echo. & echo [INFO] Running DISM /CheckHealth...
    echo. >> "%DISM_LOG%" & echo ===== DISM CheckHealth ===== >> "%DISM_LOG%" & echo. >> "%DISM_LOG%"
    DISM /Online /Cleanup-Image /CheckHealth | cmd /c "for /f "delims=" %%a in ('more') do (echo %%a & echo %%a >> ""%DISM_LOG%"" )"
    set "dism_error=!errorlevel!"

    if %dism_error% equ 0 (
        echo [SUCCESS] DISM /CheckHealth found no component store corruption.
        echo [INFO] Skipping ScanHealth and RestoreHealth.
        pause
        goto :eof
    )
    
    echo [WARN] DISM /CheckHealth indicates potential issues. Proceeding with full scan.
    pause

    :: Step 2: ScanHealth (only if CheckHealth failed or found issues)
    echo. & echo [INFO] Running DISM /ScanHealth... (This can take a while)
    echo. >> "%DISM_LOG%" & echo ===== DISM ScanHealth ===== >> "%DISM_LOG%" & echo. >> "%DISM_LOG%"
    DISM /Online /Cleanup-Image /ScanHealth | cmd /c "for /f "delims=" %%a in ('more') do (echo %%a & echo %%a >> ""%DISM_LOG%"" )"
    set "dism_error=!errorlevel!"

    if %dism_error% equ 0 (
        echo [SUCCESS] DISM /ScanHealth found no component store corruption.
        pause
        goto :eof
    )

    echo [WARN] DISM /ScanHealth found corruption. Attempting repairs.
    set "REBOOT_NEEDED=1"
    pause
    
    :: Step 3: RestoreHealth (only if ScanHealth found issues)
    echo. & echo [INFO] Running DISM /RestoreHealth... (This can take a while and may require internet)
    echo. >> "%DISM_LOG%" & echo ===== DISM RestoreHealth ===== >> "%DISM_LOG%" & echo. >> "%DISM_LOG%"
    DISM /Online /Cleanup-Image /RestoreHealth | cmd /c "for /f "delims=" %%a in ('more') do (echo %%a & echo %%a >> ""%DISM_LOG%"" )"

    if !errorlevel! equ 0 (
        echo [SUCCESS] DISM /RestoreHealth completed successfully. A reboot is required.
    ) else (
        echo [ERROR] DISM /RestoreHealth failed. Check the DISM log and CBS.log for details.
    )
    pause
goto :eof


:_show_summary
    echo.
    echo ==========================================================
    echo [COMPLETE] All processes have finished.
    echo.
    if %REBOOT_NEEDED% equ 1 (
        echo [!] A system restart is RECOMMENDED to apply all changes.
    ) else (
        echo [✓] No issues requiring a restart were detected.
    )
    echo.
    echo Logs can be found at:
    echo  - CHKDSK: %CHKDSK_LOG%
    echo  - SFC   : %SFC_LOG%
    echo  - DISM  : %DISM_LOG%
    echo ==========================================================

    :CHOICE_MENU
    echo.
    echo Final Options:
    echo   1. View CHKDSK Log
    echo   2. View SFC Log  
    echo   3. View DISM Log
    if %REBOOT_NEEDED% equ 1 (
        echo   4. Schedule System Restart (in 60 seconds)
    )
    echo   5. Exit Utility
    echo ==========================================================
    
    set "OPTION="
    set /p "OPTION=Select an option: "

    if "%OPTION%"=="1" (
        if exist "%CHKDSK_LOG%" (notepad "%CHKDSK_LOG%") else (echo [WARN] CHKDSK log not found.)
        goto CHOICE_MENU
    )
    if "%OPTION%"=="2" (
        if exist "%SFC_LOG%" (notepad "%SFC_LOG%") else (echo [WARN] SFC log not found.)
        goto CHOICE_MENU
    )
    if "%OPTION%"=="3" (
        if exist "%DISM_LOG%" (notepad "%DISM_LOG%") else (echo [WARN] DISM log not found.)
        goto CHOICE_MENU
    )
    if "%OPTION%"=="4" (
        if %REBOOT_NEEDED% equ 1 (
            echo.
            echo [INFO] System will restart in 60 seconds. Press Ctrl+C to cancel.
            shutdown /r /t 60 /c "System restart scheduled by Windows Storage Utility to complete maintenance."
            goto :END_SCRIPT
        )
    )
    if "%OPTION%"=="5" goto :END_SCRIPT

    echo [WARN] Invalid option. Please try again.
    timeout /t 2 /nobreak >nul
    goto CHOICE_MENU
goto :eof


:END_SCRIPT
echo.
echo Thank you for using the Windows Storage Utility!
endlocal
pause
exit /b
