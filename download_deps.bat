@echo off
title Download OCR Dependencies

cd /d "%~dp0"

echo.
echo  =============================================
echo   OCR Tool - Download Dependencies
echo  =============================================
echo.
echo  This script downloads all required files
echo  so the tool works WITHOUT internet / CDN.
echo.
echo  Files to download (~40 MB total):
echo    lib/tesseract.min.js      (~500 KB)
echo    lib/worker.min.js         (~200 KB)
echo    lib/tesseract-core-*.js   (~5 MB)
echo    langdata/jpn.traineddata  (~13 MB)
echo    langdata/eng.traineddata  (~12 MB)
echo.
echo  Starting download...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ProgressPreference='SilentlyContinue'; " ^
"$ErrorActionPreference='Stop'; " ^
"try { " ^
"  New-Item -ItemType Directory -Force -Path 'lib' | Out-Null; " ^
"  New-Item -ItemType Directory -Force -Path 'langdata' | Out-Null; " ^
"  $files = @( " ^
"    @{u='https://cdn.jsdelivr.net/npm/tesseract.js@4/dist/tesseract.min.js';d='lib\tesseract.min.js'}, " ^
"    @{u='https://cdn.jsdelivr.net/npm/tesseract.js@4/dist/worker.min.js';d='lib\worker.min.js'}, " ^
"    @{u='https://unpkg.com/tesseract.js-core@4/tesseract-core-lstm.wasm.js';d='lib\tesseract-core-lstm.wasm.js'}, " ^
"    @{u='https://tessdata.projectnaptha.com/4.0.0/jpn.traineddata.gz';d='langdata\jpn.traineddata.gz'}, " ^
"    @{u='https://tessdata.projectnaptha.com/4.0.0/eng.traineddata.gz';d='langdata\eng.traineddata.gz'} " ^
"  ); " ^
"  $wc = New-Object System.Net.WebClient; " ^
"  foreach ($f in $files) { " ^
"    Write-Host ('  Downloading ' + $f.d + ' ...') -NoNewline; " ^
"    $wc.DownloadFile($f.u, (Join-Path (Get-Location) $f.d)); " ^
"    $size = (Get-Item $f.d).Length; " ^
"    Write-Host (' OK (' + [math]::Round($size/1KB) + ' KB)'); " ^
"  } " ^
"  Write-Host ''; " ^
"  Write-Host '  All files downloaded successfully!'; " ^
"  Write-Host '  Next: run start.bat to launch the tool.'; " ^
"} catch { " ^
"  Write-Host ('ERROR: ' + $_.Exception.Message); " ^
"  exit 1 " ^
"}"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  [ERROR] Download failed. Check your internet connection.
)

echo.
pause
