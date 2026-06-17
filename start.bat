@echo off
title OCR Tool - Starting...

:: Move to the folder where this bat file lives
cd /d "%~dp0"

echo.
echo  =============================================
echo   OCR Tool  Local Server Launcher
echo  =============================================
echo.
echo  Folder : %~dp0
echo.

:: Check ocrtool.html exists in same folder
if not exist "ocrtool.html" (
    echo  [ERROR] ocrtool.html not found in this folder^^!
    echo.
    echo  Please put start.bat and ocrtool.html
    echo  in the SAME folder, then run again.
    echo.
    echo  Files in current folder:
    dir /b
    echo.
    pause
    exit /b
)

echo  ocrtool.html ... OK

:: Check if local dependency files are present
if exist "lib\tesseract.min.js" (
    echo  lib/ (local mode) ... OK
) else (
    echo.
    echo  NOTE: lib/ folder not found.
    echo  If you get OCR errors (Edge Tracking Prevention),
    echo  run download_deps.bat first to download local files.
    echo.
)


set PORT=8765
set URL=http://localhost:%PORT%/ocrtool.html

:: ---- Python 3 ----
where python > nul 2>&1
if %ERRORLEVEL% == 0 (
    python -c "import sys; exit(0 if sys.version_info[0]==3 else 1)" > nul 2>&1
    if %ERRORLEVEL% == 0 (
        echo  [OK] Python 3 found. Starting server...
        echo.
        echo  Open this URL in your browser:
        echo    %URL%
        echo.
        echo  Press Ctrl+C to stop the server.
        echo.
        start "" "%URL%"
        python -m http.server %PORT%
        goto :done
    )
)

:: ---- python3 command ----
where python3 > nul 2>&1
if %ERRORLEVEL% == 0 (
    echo  [OK] Python3 found. Starting server...
    echo.
    echo  Open this URL in your browser:
    echo    %URL%
    echo.
    echo  Press Ctrl+C to stop the server.
    echo.
    start "" "%URL%"
    python3 -m http.server %PORT%
    goto :done
)

:: ---- Node.js ----
where node > nul 2>&1
if %ERRORLEVEL% == 0 (
    echo  [OK] Node.js found. Starting server...
    echo.
    echo  Open this URL in your browser:
    echo    %URL%
    echo.
    echo  Press Ctrl+C to stop the server.
    echo.
    start "" "%URL%"
    npx --yes serve -p %PORT% -s .
    goto :done
)

:: ---- Nothing found ----
echo  =============================================
echo   [ERROR] Cannot start server
echo  =============================================
echo.
echo  Python or Node.js is not installed.
echo.
echo  Install Python (recommended, free):
echo    https://www.python.org/downloads/
echo.
echo    IMPORTANT: During install, check the box:
echo    "Add Python to PATH"
echo.
echo  Install Node.js (free):
echo    https://nodejs.org/
echo.
echo  After installing, run this file again.
echo.

:done
pause
