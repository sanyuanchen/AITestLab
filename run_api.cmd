@echo off
rem ============================================================
rem  Runs the FastAPI backend for QualityPilot.
rem  Called by start_qualitypilot.bat (no arguments needed).
rem  Output goes to logs\api.log
rem ============================================================
setlocal EnableExtensions
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "PY=%ROOT%\.venv\Scripts\python.exe"
set "LOG=%ROOT%\logs\api.log"
set "NO_PROXY=127.0.0.1,localhost"
set "no_proxy=127.0.0.1,localhost"

if not exist "%ROOT%\logs" mkdir "%ROOT%\logs" >nul 2>&1
if not exist "%PY%" (
  echo [ERROR] venv python not found: %PY% >> "%LOG%"
  exit /b 1
)

cd /d "%ROOT%"
echo ==== API start %DATE% %TIME% ====>> "%LOG%"
"%PY%" -m uvicorn src.api.main:app --host 127.0.0.1 --port 8000 >> "%LOG%" 2>&1
echo ==== API exited %DATE% %TIME% ====>> "%LOG%"
