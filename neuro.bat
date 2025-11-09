@echo off
REM Neuro AI VTuber - Windows Control Script
REM Simple control script for managing the Neuro AI VTuber application on Windows

setlocal enabledelayedexpansion

REM Configuration
set "VENV_NAME=venv"
set "MAIN_SCRIPT=main.py"
set "LOG_FILE=neuro.log"

REM Get script directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Parse command
if "%1"=="" goto :show_help
if /i "%1"=="start" goto :start_app
if /i "%1"=="background" goto :start_background
if /i "%1"=="daemon" goto :start_background
if /i "%1"=="stop" goto :stop_app
if /i "%1"=="status" goto :show_status
if /i "%1"=="logs" goto :show_logs
if /i "%1"=="help" goto :show_help
if /i "%1"=="--help" goto :show_help
if /i "%1"=="-h" goto :show_help

echo [ERROR] Unknown command: %1
echo.
echo Run 'neuro help' for usage information
exit /b 1

:start_app
echo [INFO] Starting Neuro AI VTuber...
echo.

REM Check if venv exists
if not exist "%VENV_NAME%\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found. Please run install.sh first.
    exit /b 1
)

REM Check if .env exists
if not exist ".env" (
    echo [ERROR] .env file not found. Please configure your environment.
    exit /b 1
)

REM Check if main.py exists
if not exist "%MAIN_SCRIPT%" (
    echo [ERROR] %MAIN_SCRIPT% not found.
    exit /b 1
)

echo [INFO] Starting application in foreground mode...
echo [INFO] Press CTRL+C to stop
echo.

REM Activate venv and run
call "%VENV_NAME%\Scripts\activate.bat"
python "%MAIN_SCRIPT%"
goto :eof

:start_background
echo [INFO] Starting Neuro AI VTuber in background...
echo.
echo [WARN] Background mode on Windows requires additional tools.
echo [INFO] Recommended: Use Windows Task Scheduler or run in foreground mode.
echo.
echo Starting in new window instead...
echo.

REM Check if venv exists
if not exist "%VENV_NAME%\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found. Please run install.sh first.
    exit /b 1
)

REM Start in new window
start "Neuro AI VTuber" cmd /k "cd /d %SCRIPT_DIR% && call %VENV_NAME%\Scripts\activate.bat && python %MAIN_SCRIPT%"
echo [SUCCESS] Neuro started in new window
goto :eof

:stop_app
echo [INFO] To stop Neuro, close the window where it's running or press CTRL+C
echo.
echo [WARN] Automated stop not available on Windows without additional tools.
echo [INFO] Consider using Task Manager if the process is unresponsive.
goto :eof

:show_status
echo.
echo ========================================================
echo          Neuro AI VTuber - Status
echo ========================================================
echo.

REM Check if process is running (simple check)
tasklist /FI "IMAGENAME eq python.exe" 2>NUL | find /I "python.exe" >NUL
if %ERRORLEVEL%==0 (
    echo [INFO] Python processes are running
    echo [INFO] Neuro may be running - check the application window
) else (
    echo [WARN] No Python processes detected
)
echo.

REM Check if log file exists
if exist "%LOG_FILE%" (
    echo [INFO] Log file: %LOG_FILE%
    echo [INFO] Last modified:
    for %%A in ("%LOG_FILE%") do echo   %%~tA
) else (
    echo [INFO] No log file found
)
echo.
goto :eof

:show_logs
if not exist "%LOG_FILE%" (
    echo [WARN] No log file found: %LOG_FILE%
    exit /b 1
)

if /i "%2"=="-f" goto :follow_logs
if /i "%2"=="--follow" goto :follow_logs

REM Show last 50 lines (Windows equivalent)
echo Showing last 50 lines of %LOG_FILE%:
echo ========================================================
powershell -Command "Get-Content '%LOG_FILE%' -Tail 50"
goto :eof

:follow_logs
echo Following %LOG_FILE% (press CTRL+C to stop):
echo ========================================================
powershell -Command "Get-Content '%LOG_FILE%' -Wait -Tail 50"
goto :eof

:show_help
echo.
echo ========================================================
echo          Neuro AI VTuber - Control Script
echo ========================================================
echo.
echo Usage: neuro.bat ^<command^>
echo.
echo Commands:
echo   start         Start Neuro in foreground (interactive mode)
echo   background    Start Neuro in new window
echo   stop          Instructions to stop Neuro
echo   status        Show Neuro status
echo   logs          Show recent logs
echo   logs -f       Follow logs in real-time
echo   help          Show this help message
echo.
echo Examples:
echo   neuro.bat start       # Start interactively
echo   neuro.bat background  # Start in new window
echo   neuro.bat status      # Check if running
echo   neuro.bat logs -f     # Watch logs live
echo.
echo Note: For better process management on Windows, consider using
echo       the Python launcher: python launcher.py
echo.
goto :eof
