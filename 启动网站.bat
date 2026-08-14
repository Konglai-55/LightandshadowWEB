@echo off
setlocal EnableExtensions
title Website Server

cd /d "%~dp0"

set "PORT=5000"
set "SITE_URL=http://127.0.0.1:%PORT%/"
set "NO_OPEN="
if /i "%~1"=="--no-open" set "NO_OPEN=1"

rem Open the existing site if this port is already serving HTTP.
powershell -NoProfile -Command "try { $r = Invoke-WebRequest -Uri '%SITE_URL%' -UseBasicParsing -TimeoutSec 1; if ($r.StatusCode -eq 200) { exit 0 } } catch {}; exit 1" >nul 2>nul
if not errorlevel 1 (
    echo Website is already running at %SITE_URL%
    if not defined NO_OPEN start "" "%SITE_URL%"
    echo Press any key to close this window.
    pause >nul
    exit /b 0
)

rem Try commands registered in PATH.
python --version >nul 2>nul
if not errorlevel 1 (
    set "PYTHON_EXE=python"
    set "PYTHON_ARGS="
    goto :start_server
)

py -3 --version >nul 2>nul
if not errorlevel 1 (
    set "PYTHON_EXE=py"
    set "PYTHON_ARGS=-3"
    goto :start_server
)

rem Search common per-user and system installation folders.
for /d %%D in ("%LocalAppData%\Programs\Python\Python*") do if exist "%%~fD\python.exe" (
    set "PYTHON_EXE=%%~fD\python.exe"
    set "PYTHON_ARGS="
    goto :start_server
)

for /d %%D in ("%ProgramFiles%\Python*") do if exist "%%~fD\python.exe" (
    set "PYTHON_EXE=%%~fD\python.exe"
    set "PYTHON_ARGS="
    goto :start_server
)

for /d %%D in ("C:\Python*") do if exist "%%~fD\python.exe" (
    set "PYTHON_EXE=%%~fD\python.exe"
    set "PYTHON_ARGS="
    goto :start_server
)

rem Codex bundled Python fallback for the development computer.
set "BUNDLED_PYTHON=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if exist "%BUNDLED_PYTHON%" (
    set "PYTHON_EXE=%BUNDLED_PYTHON%"
    set "PYTHON_ARGS="
    goto :start_server
)

echo.
echo ERROR: Python was not found.
echo Run "where python" and "py -0p" in Command Prompt.
echo Reinstall Python with "Add Python to PATH" enabled if both fail.
echo.
pause
exit /b 1

:start_server
echo.
echo ==============================================
echo Website server started successfully.
echo Local URL: %SITE_URL%
echo Port: %PORT%
echo Python: %PYTHON_EXE% %PYTHON_ARGS%
echo Close this window to stop the server.
echo ==============================================
echo.

if not defined NO_OPEN start "" powershell -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Milliseconds 900; Start-Process '%SITE_URL%'"

"%PYTHON_EXE%" %PYTHON_ARGS% -m http.server %PORT% --bind 0.0.0.0

echo.
echo Website server stopped.
pause
endlocal
