@echo off
setlocal enabledelayedexpansion
title XAMPP Flexible Recovery Tool

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ERROR: Administrative privileges are required.
    echo     Please right-click this script and select "Run as administrator".
    pause
    exit /b
)

echo ==================================================
echo       XAMPP DATABASE AUTO-RECOVERY SYSTEM
echo ==================================================
echo.

:: Input XAMPP Directory Path
set /p "USER_PATH=Input XAMPP path (Ex: D:\xampp) or hit ENTER for default [C:\xampp]: "

if "%USER_PATH%"=="" (
    set "XAMPP_PATH=C:\xampp"
) else (
    set "XAMPP_PATH=%USER_PATH%"
)

:: Validate MySQL directory existence
set "MYSQL_PATH=%XAMPP_PATH%\mysql"
if not exist "%MYSQL_PATH%" (
    echo.
    echo [!] ERROR: XAMPP directory not found at: %XAMPP_PATH%
    echo     Please verify the path and try again.
    pause
    exit /b
)

echo.
echo [+] Target Path: %XAMPP_PATH%
echo.

:: Terminating XAMPP services and processes
echo [+] Terminating XAMPP processes...
taskkill /F /IM xampp-control.exe /T 2>nul
taskkill /F /IM httpd.exe /T 2>nul
taskkill /F /IM mysqld.exe /T 2>nul
timeout /t 2 >nul

:: 4. Archive existing data directory with timestamp
set "tstamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%"
set "tstamp=%tstamp: =0%"
echo [+] Archiving corrupted data to: data_corrupted_%tstamp%...
rename "%MYSQL_PATH%\data" "data_corrupted_%tstamp%"

:: 5. Initialize new data directory from XAMPP baseline backup
echo [+] Rebuilding data structure from baseline backup...
mkdir "%MYSQL_PATH%\data"
xcopy "%MYSQL_PATH%\backup\*" "%MYSQL_PATH%\data\" /s /e /y >nul

:: 6. Migrate User Databases & ibdata1 system file
echo [+] Restoring user databases and ibdata1 file...
for /d %%i in ("%MYSQL_PATH%\data_corrupted_%tstamp%\*") do (
    set "foldername=%%~nxi"
    :: Exclude internal system schemas
    if /i not "!foldername!"=="mysql" if /i not "!foldername!"=="performance_schema" if /i not "!foldername!"=="phpmyadmin" if /i not "!foldername!"=="test" (
        echo     - Migrating: !foldername!
        xcopy "%%i" "%MYSQL_PATH%\data\!foldername!\" /s /e /y >nul
    )
)

:: Transfer ibdata1 (Essential for InnoDB tables)
copy /y "%MYSQL_PATH%\data_corrupted_%tstamp%\ibdata1" "%MYSQL_PATH%\data\" >nul

echo.
echo ==================================================
echo   [SUCCESS] RECOVERY PROCESS COMPLETE
echo   All user databases have been migrated to the new directory.
echo   You may now restart the XAMPP Control Panel.
echo ==================================================
pause