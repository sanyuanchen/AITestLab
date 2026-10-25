@echo off
rem ============================================================
rem  Runs the Vite dev server for QualityPilot.
rem  Called by start_qualitypilot.bat (no arguments needed).
rem  Output goes to logs\web.log
rem ============================================================
setlocal EnableExtensions
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "WEB=%ROOT%\frontend\qualitypilot-web"
set "LOG=%ROOT%\logs\web.log"
set "NO_PROXY=127.0.0.1,localhost"
set "no_proxy=127.0.0.1,localhost"

if not exist "%ROOT%\logs" mkdir "%ROOT%\logs" >nul 2>&1

rem --- locate npm.cmd ---
set "NPMCMD="
for /f "delims=" %%I in ('where npm.cmd 2^>nul') do if not defined NPMCMD set "NPMCMD=%%I"
if not defined NPMCMD for /d %%D in ("%USERPROFILE%\.workbuddy\binaries\node\versions\*") do if not defined NPMCMD if exist "%%~fD\npm.cmd" set "NPMCMD=%%~fD\npm.cmd"
if not defined NPMCMD if exist "C:\Program Files\nodejs\npm.cmd" set "NPMCMD=C:\Program Files\nodejs\npm.cmd"
if not defined NPMCMD if exist "%APPDATA%\npm\npm.cmd" set "NPMCMD=%APPDATA%\npm\npm.cmd"

if not defined NPMCMD goto no_npm

rem vite's shim calls bare "node", so put node.exe's folder first on PATH
for %%I in ("%NPMCMD%") do set "PATH=%%~dpI;%PATH%"

cd /d "%WEB%"
echo ==== WEB start %DATE% %TIME% ====>> "%LOG%"
echo npm: %NPMCMD% >> "%LOG%"
call "%NPMCMD%" run dev >> "%LOG%" 2>&1
echo ==== WEB exited %DATE% %TIME% ====>> "%LOG%"
exit /b 0

:no_npm
echo [ERROR] npm.cmd not found on PATH >> "%LOG%"
echo [ERROR] npm.cmd not found. Install Node.js 18+ or fix PATH.
pause
exit /b 1
