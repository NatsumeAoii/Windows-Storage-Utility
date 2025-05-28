@echo off
title Pemeriksaan Otomatis CHKDSK, SFC, dan DISM (Dengan Konfirmasi)
color 0A

:: Cek apakah dijalankan sebagai Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Skrip ini harus dijalankan sebagai Administrator.
    echo [!] Klik kanan dan pilih "Run as administrator".
    pause
    exit /b
)

:input_drive
cls
echo ========================================================
echo      WINDOWS STORAGE UTILITY (CHKDSK + SFC + DISM) v0.5
echo ========================================================
echo.
set /p DRIVE_LETTER=Masukkan huruf drive yang ingin diperiksa CHKDSK (misal: C, D, E): 

:: Ubah ke huruf besar
call set DRIVE_UC=%%DRIVE_LETTER:~0,1%%
for %%A in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if /I "%DRIVE_LETTER%"=="%%A" set DRIVE_UC=%%A
)

set DRIVE=%DRIVE_UC%:

:: Konfirmasi input
:confirm_input
echo.
echo [✓] Sistem yang akan diperiksa adalah drive: %DRIVE%
set /p CONFIRM=Apakah sudah benar? (Y/N): 

if /I "%CONFIRM%"=="Y" goto mulai_proses
if /I "%CONFIRM%"=="N" goto input_drive

echo [!] Input tidak dikenali. Harap ketik Y atau N saja.
goto confirm_input

:mulai_proses
:: Jalankan CHKDSK
echo.
echo [1/4] Menjalankan CHKDSK pada drive %DRIVE% ...
chkdsk %DRIVE% /f /r
echo.
echo [!] Jika ini adalah drive sistem, proses akan dijadwalkan saat restart.
pause

:: Jalankan SFC
echo.
echo [2/4] Menjalankan SFC (System File Checker)...
sfc /scannow
echo.
echo [✓] SFC selesai dijalankan.
pause

:: Jalankan DISM
echo.
echo [3/4] Menjalankan DISM - CheckHealth...
DISM /Online /Cleanup-Image /CheckHealth
echo.

echo [4/4] Menjalankan DISM - ScanHealth...
DISM /Online /Cleanup-Image /ScanHealth
echo.

echo Menjalankan DISM - RestoreHealth...
DISM /Online /Cleanup-Image /RestoreHealth
echo.

echo ==========================================================
echo Semua proses selesai. Disarankan untuk merestart PC Anda.
echo Log dapat ditemukan di:
echo - SFC  : C:\Windows\Logs\CBS\CBS.log
echo - DISM : C:\Windows\Logs\DISM\dism.log
echo ==========================================================
pause
