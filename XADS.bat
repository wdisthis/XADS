@echo off
setlocal enabledelayedexpansion
title XAMPP Flexible Recovery Tool

:: --- 1. ANSI Color Support Detection ---
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "USE_COLOR=0"
:: Check Windows build (Version 1607 is 14393)
for /f "tokens=4-6 delims=[]. " %%i in ('ver') do (
    if %%i geq 10 (
        if %%k geq 14393 set "USE_COLOR=1"
    )
)

if "%USE_COLOR%"=="1" (
    set "C_RED=%ESC%[91m"
    set "C_GREEN=%ESC%[92m"
    set "C_YELLOW=%ESC%[93m"
    set "C_CYAN=%ESC%[96m"
    set "C_WHITE=%ESC%[97m"
    set "C_RESET=%ESC%[0m"
    set "C_BOLD=%ESC%[1m"
) else (
    set "C_RED=" & set "C_GREEN=" & set "C_YELLOW=" & set "C_CYAN=" & set "C_WHITE=" & set "C_RESET=" & set "C_BOLD="
)

:: --- 2. Administrative Privileges Check ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %C_RED%[!] ERROR: Administrative privileges are required.%C_RESET%
    echo     Please right-click this script and select "Run as administrator".
    pause
    exit /b
)

:: --- 3. Welcome Header ---
cls
echo %C_CYAN%==================================================%C_RESET%
echo %C_BOLD%%C_WHITE%    XAMPP DATABASE AUTO-RECOVERY SYSTEM%C_RESET%
echo %C_CYAN%==================================================%C_RESET%
echo.


:: --- 4. Input XAMPP Directory Path ---
echo %C_CYAN%[i]%C_RESET% Please specify your XAMPP installation path.
set /p "USER_PATH=   Path (Default: C:\xampp): "

if "%USER_PATH%"=="" (
    set "XAMPP_PATH=C:\xampp"
) else (
    set "XAMPP_PATH=%USER_PATH%"
)

set "MYSQL_PATH=%XAMPP_PATH%\mysql"
if not exist "%MYSQL_PATH%" (
    echo.
    echo %C_RED%[^!] ERROR: MySQL directory not found at: %XAMPP_PATH%%C_RESET%
    echo     Please verify the path and try again.
    pause
    exit /b
)

echo.
echo %C_GREEN%[+] Target Path confirmed:%C_RESET% %XAMPP_PATH%
echo.

:: --- 5. Confirmation Prompt ---
echo %C_YELLOW%[!] WARNING: This will terminate all XAMPP processes%C_RESET%
echo %C_YELLOW%    and archive your current data folder.%C_RESET%
set /p "CONFIRM=    Are you sure you want to proceed? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo %C_RED%[^!] Operation cancelled by user.%C_RESET%
    timeout /t 3 >nul
    exit /b
)

:: --- 6. Terminating Processes ---
echo.
echo %C_CYAN%[i] Step 1: Terminating XAMPP processes...%C_RESET%
taskkill /F /IM xampp-control.exe /T 2>nul
taskkill /F /IM httpd.exe /T 2>nul
taskkill /F /IM mysqld.exe /T 2>nul
timeout /t 2 >nul
echo     %C_GREEN%Done.%C_RESET%

:: --- 7. Archiving Corrupted Data ---
:: Get locale-independent timestamp using PowerShell
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmm'"') do set "tstamp=%%i"

echo.
echo %C_CYAN%[i] Step 2: Archiving corrupted data...%C_RESET%
echo     Path: data_corrupted_%tstamp%
rename "%MYSQL_PATH%\data" "data_corrupted_%tstamp%"
if %errorLevel% neq 0 (
    echo %C_RED%[^!] FAILED to rename data folder. Is it still in use?%C_RESET%
    pause
    exit /b
)
echo     %C_GREEN%Done.%C_RESET%

:: --- 8. Rebuilding Data Structure ---
echo.
echo %C_CYAN%[i] Step 3: Rebuilding data structure from backup...%C_RESET%
mkdir "%MYSQL_PATH%\data"
xcopy "%MYSQL_PATH%\backup\*" "%MYSQL_PATH%\data\" /s /e /y >nul
echo     %C_GREEN%Done.%C_RESET%

:: --- 9. Migrating Databases (With Progress) ---
echo.
echo %C_CYAN%[i] Step 4: Restoring user databases...%C_RESET%

:: Count folders first for progress
set "count=0"
for /d %%i in ("%MYSQL_PATH%\data_corrupted_%tstamp%\*") do (
    set "foldername=%%~nxi"
    if /i not "!foldername!"=="mysql" if /i not "!foldername!"=="performance_schema" if /i not "!foldername!"=="phpmyadmin" if /i not "!foldername!"=="test" (
        set /a count+=1
    )
)

set "current=0"
for /d %%i in ("%MYSQL_PATH%\data_corrupted_%tstamp%\*") do (
    set "foldername=%%~nxi"
    if /i not "!foldername!"=="mysql" if /i not "!foldername!"=="performance_schema" if /i not "!foldername!"=="phpmyadmin" if /i not "!foldername!"=="test" (
        set /a current+=1
        set /a "percent=(current * 100) / count"
        
        :: Simple progress bar
        <nul set /p "=    Migrating [!current!/%count%] !foldername! ... "
        xcopy "%%i" "%MYSQL_PATH%\data\!foldername!\" /s /e /y >nul
        echo %C_GREEN%OK%C_RESET%
    )
)

:: --- 10. Transfer ibdata1 ---
echo.
echo %C_CYAN%[i] Step 5: Finalizing system files...%C_RESET%
copy /y "%MYSQL_PATH%\data_corrupted_%tstamp%\ibdata1" "%MYSQL_PATH%\data\" >nul
echo     %C_GREEN%ibdata1 restored.%C_RESET%

:: --- 11. Success Message ---
echo.
echo %C_CYAN%==================================================%C_RESET%
echo %C_GREEN%%C_BOLD%         [SUCCESS] RECOVERY COMPLETE!           %C_RESET%
echo %C_CYAN%==================================================%C_RESET%
echo.
echo %C_WHITE%All user databases have been safely migrated.%C_RESET%
echo.

:: --- 12. Reopen XAMPP Option ---
set /p "OPEN_XAMPP=Would you like to open XAMPP Control Panel now? (Y/N): "
if /i "%OPEN_XAMPP%"=="Y" (
    echo %C_CYAN%[i] Starting XAMPP Control Panel...%C_RESET%
    start "" "%XAMPP_PATH%\xampp-control.exe"
)


echo.
echo %C_YELLOW%Press any key to exit...%C_RESET%
pause >nul
exit /b