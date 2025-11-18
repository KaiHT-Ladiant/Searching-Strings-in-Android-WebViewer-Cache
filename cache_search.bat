@echo off
:: Set Encoding Type "ANSI" to save.
:: Version 1.0
:: chcp 65001 > nul
title Android WebView Cache Searching Tool

setlocal enabledelayedexpansion

:: Get CLI Width
for /f %%W in ('powershell -Command "(Get-Host).UI.RawUI.WindowSize.Width"') do set "width=%%W"
:: Android WebView Cache Searching (Rooted Device)
:: Scripting By Kai_HT
echo ┌─────────────────────────────────┓
echo │      Searching Information      ┃ 
echo │   in Rooting Devices from Cache ┃
echo ┕━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
echo.

set /p PACKAGE=Input Application Package Name: 
if "%PACKAGE%"=="" (
    echo [ERROR] Input Your Package Name..
    pause
    exit /b
)

echo.
call :printline
echo Cache Path Settings:
call :printline
echo [1] Value in Objection env 
echo [2] User's Input Value
echo [3] Use Default Path (/data/data, /data/user/0)
echo.
set /p PATH_OPTION=Select (1/2/3): 

set "CACHE_PATHS="

if "%PATH_OPTION%"=="1" (
    echo.
    echo [INFO] Bring Cache Path by Objection.
    echo [INFO] Application have to run in Devices.. 
    echo.
    set TEMP_ENV=%TEMP%\objection_env_%RANDOM%.txt
    objection -g %PACKAGE% explore --quiet --startup-command "env" > "!TEMP_ENV!" 2>&1
    if errorlevel 1 (
        echo [WARN] Objection Detected Failed. Setting Default Paths.
        set CACHE_PATHS=/data/data/%PACKAGE%/cache /data/user/0/%PACKAGE%/cache
    ) else (
        for /f "tokens=2" %%A in ('findstr /C:"cacheDirectory" "!TEMP_ENV!"') do (
            set CACHE_PATHS=%%A
            echo [OK] Search Cache Path: %%A
        )
        
        if "!CACHE_PATHS!"=="" (
            echo [WARN] Can't Find Cache Path. Use Default Path.
            set CACHE_PATHS=/data/data/%PACKAGE%/cache /data/user/0/%PACKAGE%/cache
        )
        del "!TEMP_ENV!" 2>nul
    )
) else if "%PATH_OPTION%"=="2" (
    echo.
    echo Input Cache Path.
    echo Example: /data/user/0/[PackageName]/cache
    echo.
    set /p CACHE_PATHS=Path: 
    
    if "!CACHE_PATHS!"=="" (
        echo [ERROR] Input Paths Value.
        pause
        exit /b
    )
) else (
    echo [INFO] Use Default Paths
    set CACHE_PATHS=/data/data/%PACKAGE%/cache /data/user/0/%PACKAGE%/cache
)
echo.

set /p SEARCH_STRING=String Value: 
if "%SEARCH_STRING%"=="" (
    echo [ERROR] Input Searching Strings...
    pause
    exit /b
)
    
echo.
call :printline
echo [INFO] Package Name: %PACKAGE%
echo [INFO] Searching String: %SEARCH_STRING%
call :printline
echo.

echo [1/5] Checking ADB Devices...
adb devices | findstr "device$" > nul
if errorlevel 1 (
    echo [ERROR] Not Connected ADB Device.
    pause
    exit /b
)
echo [OK] ADB Device Connected.
echo.

echo [2/5] Checking Root Permission...
adb shell "su -c 'id'" 2>nul | findstr "uid=0" > nul
if errorlevel 1 (
    echo [WARN] You haven't Root permission.
    echo Use run-as Methods.
    set USE_ROOT=0
) else (
    echo [OK] Checked ROOT Permission
    set USE_ROOT=1
)
echo.

set TEMP_FILE_LIST=%TEMP%\cache_files_%RANDOM%.txt
set TEMP_RESULT=%TEMP%\search_result_%RANDOM%.txt

echo [3/5] Getting CacheFile List...
if exist %TEMP_FILE_LIST% del %TEMP_FILE_LIST%

for %%P in (%CACHE_PATHS%) do (
    if !USE_ROOT! equ 1 (
        adb shell "su -c 'if [ -d %%P ]; then find %%P -type f 2>/dev/null; fi'" >> %TEMP_FILE_LIST%
    ) else (
        adb shell "run-as %PACKAGE% find %%P -type f 2>/dev/null" >> %TEMP_FILE_LIST%
    )
)

if not exist %TEMP_FILE_LIST% (
    echo [ERROR] Can't Getting Cache File List..
    pause
    exit /b
)

for /f %%A in ('type %TEMP_FILE_LIST% ^| find /c /v ""') do set FILE_COUNT=%%A
if %FILE_COUNT% equ 0 (
    echo [ERROR] Can't Find Cache File
    echo.
    echo CheckList: 
    echo - Package Name is Real?
    echo - Webcache Created By Running Application?
    echo - Path is Real?
    del %TEMP_FILE_LIST%
    pause
    exit /b
)

echo [OK] Check CacheFile List: %FILE_COUNT%
echo.

echo [4/5] Searching File Contents...
echo (Binary files also searched - may take time)
echo.
set FOUND_COUNT=0
set CURRENT=0

if exist %TEMP_RESULT% del %TEMP_RESULT%

for /f "usebackq delims=" %%F in ("%TEMP_FILE_LIST%") do (
    set /a CURRENT+=1
    set "FILE_PATH=%%F"
    
    set /a MOD=!CURRENT! %% 10
    if !MOD! equ 0 echo [RUNNING] !CURRENT!/%FILE_COUNT% File Searching Complete...
    
    if !USE_ROOT! equ 1 (
        adb shell "su -c 'grep -a -i \"%SEARCH_STRING%\" \"%%F\" 2>/dev/null'" > nul
    ) else (
        adb shell "run-as %PACKAGE% grep -a -i \"%SEARCH_STRING%\" \"%%F\" 2>/dev/null" > nul
    )
    
    if !errorlevel! equ 0 (
        set /a FOUND_COUNT+=1
        echo.
        echo [FOUND !FOUND_COUNT!] %%F
        echo ========================================= >> %TEMP_RESULT%
        echo FILE: %%F >> %TEMP_RESULT%
        echo ========================================= >> %TEMP_RESULT%
        
        if !USE_ROOT! equ 1 (
            adb shell "su -c 'grep -a -i -n \"%SEARCH_STRING%\" \"%%F\" 2>/dev/null | head -50'" >> %TEMP_RESULT%
        ) else (
            adb shell "run-as %PACKAGE% grep -a -i -n \"%SEARCH_STRING%\" \"%%F\" 2>/dev/null" >> %TEMP_RESULT%
        )
        echo. >> %TEMP_RESULT%
        echo. >> %TEMP_RESULT%
    )    
)

echo.
echo [5/5] Searching Complete.
call :printline
echo Search Result: Strings in %FOUND_COUNT% Files
call :printline
echo. 

if %FOUND_COUNT% gtr 0 (
    echo Result:
    echo.
    type %TEMP_RESULT%
    echo.
    call :printline
    echo Save Result? (Y/N)
    set /p SAVE_OPTION=Select: 
    
    if /i "!SAVE_OPTION!"=="Y" (
        set OUTPUT_FILE=cache_search_%PACKAGE%_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt
        set OUTPUT_FILE=!OUTPUT_FILE: =0!
        copy %TEMP_RESULT% "!OUTPUT_FILE!" > nul
        echo [OK] Result is Saved: !OUTPUT_FILE!
        echo.
        echo Open File? (Y/N)
        set /p OPEN_OPTION=Select: 
        if /i "!OPEN_OPTION!"=="Y" notepad "!OUTPUT_FILE!"
    )
) else (
    echo [INFO] Can't Find File including Strings
)

if exist %TEMP_FILE_LIST% del %TEMP_FILE_LIST%
if exist %TEMP_RESULT% del %TEMP_RESULT%

echo.
pause
exit /b

:printline
set "line="
for /l %%i in (1,1,%width%) do set "line=!line!─"
echo !line!
goto :eof
