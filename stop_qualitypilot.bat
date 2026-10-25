@echo off
rem ============================================================
rem  QualityPilot stopper - frees ports 8000 / 5173
rem ============================================================
setlocal EnableExtensions
echo Stopping QualityPilot services ...

call :killport 8000
call :killport 5173

echo Done.
"%SystemRoot%\System32\timeout.exe" /t 2 /nobreak >nul 2>&1
exit /b 0

:killport
for /f "tokens=5" %%I in ('netstat -ano ^| findstr /C:"127.0.0.1:%1 " ^| findstr /C:"LISTENING"') do (
  echo   killing PID %%I on port %1
  taskkill /PID %%I /F >nul 2>&1
)
exit /b 0
