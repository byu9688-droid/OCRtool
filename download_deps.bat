@echo off
title Download OCR Dependencies

cd /d "%~dp0"

echo.
echo  Starting download script...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download_deps.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  PowerShell error. Press any key to exit.
    pause > nul
)
