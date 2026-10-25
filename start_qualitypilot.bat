@echo off
rem ============================================================
rem  QualityPilot one-click launcher
rem  Double-click the desktop shortcut: starts whatever is
rem  missing, then opens the web UI in the default browser.
rem  All steps are logged to logs\launcher.log
rem ============================================================
setlocal EnableExtensions
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "PY=%ROOT%\.venv\Scripts\python.exe"
set "WEB=%ROOT%\frontend\qualitypilot-web"
set "URL=http://127.0.0.1:5173"
set "LOG=%ROOT%\logs\launcher.log"
set "NO_PROXY=127.0.0.1,localhost"
set "no_proxy=127.0.0.1,localhost"

if not exist "%ROOT%\logs" mkdir "%ROOT%\logs" >nul 2>&1
call :log "----- launcher start -----"

if not exist "%PY%" goto no_venv
if not exist "%WEB%\package.json" goto no_frontend

call :port_open 8000
if errorlevel 1 goto start_api
call :log "[1/3] Backend already running, skip."
goto check_web

:start_api
call :log "[1/3] Starting FastAPI backend on port 8000 ..."
start "QualityPilot-API" /min "%ROOT%\run_api.cmd"

:check_web
call :port_open 5173
if errorlevel 1 goto start_web
call :log "[2/3] Frontend already running, skip."
goto wait_ready

:start_web
call :find_npm
if not defined NPMCMD goto no_npm
call :log "[2/3] Starting Vue frontend with %NPMCMD%"
start "QualityPilot-Web" /min "%ROOT%\run_web.cmd"

:wait_ready
call :log "[3/3] Waiting for %URL% ..."
set /a tries=0

:wait_loop
call :http_ok
if not errorlevel 1 goto open
set /a tries+=1
if %tries% GEQ 45 goto open_anyway
call :sleep2
goto wait_loop

:open
call :log "Ready. Opening browser."
call :open_browser
call :sleep2
call :log "----- launcher done -----"
exit /b 0

:open_anyway
call :log "[!] Web UI did not answer in time, opening browser anyway."
call :open_browser
call :log "----- launcher done (timeout) -----"
echo.
echo [!] The web UI did not answer in time.
echo     Check the "QualityPilot-API" / "QualityPilot-Web" windows for errors.
echo     Log: %LOG%
pause
exit /b 0

:no_venv
call :log "[ERROR] venv not found: %PY%"
echo [ERROR] Python virtual environment not found:
echo         %PY%
pause
exit /b 1

:no_frontend
call :log "[ERROR] frontend not found: %WEB%"
echo [ERROR] Vue frontend not found: %WEB%
pause
exit /b 1

:no_npm
call :log "[ERROR] npm.cmd not found on PATH"
echo [ERROR] Could not find npm.cmd.
echo Install Node.js 18+ and make sure it is on PATH, then retry.
pause
exit /b 1

:find_npm
set "NPMCMD="
for /f "delims=" %%I in ('where npm.cmd 2^>nul') do if not defined NPMCMD set "NPMCMD=%%I"
if defined NPMCMD exit /b 0
rem bundled node shipped with this workspace tool (verified on this machine)
for /d %%D in ("%USERPROFILE%\.workbuddy\binaries\node\versions\*") do if not defined NPMCMD if exist "%%~fD\npm.cmd" set "NPMCMD=%%~fD\npm.cmd"
if defined NPMCMD exit /b 0
if exist "C:\Program Files\nodejs\npm.cmd" set "NPMCMD=C:\Program Files\nodejs\npm.cmd"
if defined NPMCMD exit /b 0
if exist "%APPDATA%\npm\npm.cmd" set "NPMCMD=%APPDATA%\npm\npm.cmd"
exit /b 0

:open_browser
set "BROWSER="
call :try_browser "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if defined BROWSER goto launch_browser
call :try_browser "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if defined BROWSER goto launch_browser
call :try_browser "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if defined BROWSER goto launch_browser
call :try_browser "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if defined BROWSER goto launch_browser
call :try_browser "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if defined BROWSER goto launch_browser
call :try_browser "%ProgramFiles%\Mozilla Firefox\firefox.exe"
if defined BROWSER goto launch_browser
goto open_default

:try_browser
if defined BROWSER exit /b 0
if exist %1 set "BROWSER=%~1"
exit /b 0

:launch_browser
call :log "open: %BROWSER% %URL%"
start "" "%BROWSER%" "%URL%"
exit /b 0

:open_default
call :log "open: no known browser found, trying system default"
powershell -NoProfile -WindowStyle Hidden -Command "Start-Process '%URL%'" >>"%LOG%" 2>&1
if not errorlevel 1 exit /b 0
call :log "open: falling back to explorer.exe"
"%SystemRoot%\explorer.exe" "%URL%"
exit /b 0

:sleep2
"%SystemRoot%\System32\timeout.exe" /t 2 /nobreak >nul 2>&1
if errorlevel 1 ping -n 3 127.0.0.1 >nul 2>&1
exit /b 0

:port_open
netstat -ano | findstr /C:"127.0.0.1:%1 " | findstr /C:"LISTENING" >nul
exit /b %errorlevel%

:http_ok
"%SystemRoot%\System32\curl.exe" -sf --noproxy "*" -m 3 -o nul "%URL%/"
exit /b %errorlevel%

:log
echo %~1
>>"%LOG%" echo [%DATE% %TIME%] %~1
exit /b 0
