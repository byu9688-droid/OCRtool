# start.ps1 - Launch local HTTP server for OCR Tool
Set-Location $PSScriptRoot

$PORT = 8765
$URL  = "http://localhost:$PORT/ocrtool.html"

Write-Host ""
Write-Host "  ============================================="
Write-Host "   OCR Tool  Local Server"
Write-Host "  ============================================="
Write-Host ""
Write-Host "  Folder : $PSScriptRoot"
Write-Host ""

# Check ocrtool.html exists
if (-not (Test-Path "ocrtool.html")) {
    Write-Host "  [ERROR] ocrtool.html not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Put start.bat / start.ps1 and ocrtool.html"
    Write-Host "  in the SAME folder, then run again."
    Write-Host ""
    Write-Host "  Files here:"
    Get-ChildItem -Name | ForEach-Object { Write-Host "    $_" }
    Write-Host ""
    Write-Host "Press Enter to close..."
    Read-Host | Out-Null
    exit 1
}
Write-Host "  ocrtool.html ........... OK" -ForegroundColor Green

# Check local lib/ mode
if (Test-Path "lib\tesseract.min.js") {
    Write-Host "  lib\ (local mode) ...... OK" -ForegroundColor Green
} else {
    Write-Host "  lib\ not found -- run download_deps.bat first" -ForegroundColor Yellow
}
Write-Host ""

# ---- Try Python 3 ----
$python = $null
foreach ($cmd in @("python","python3")) {
    try {
        $ver = & $cmd -c "import sys; print(sys.version_info[0])" 2>$null
        if ($ver -eq "3") { $python = $cmd; break }
    } catch {}
}

if ($python) {
    Write-Host "  [OK] $python found. Starting server on port $PORT ..." -ForegroundColor Green
    Write-Host ""
    Write-Host "  URL : $URL"
    Write-Host "  Stop: press Ctrl+C in this window"
    Write-Host ""
    Start-Process $URL
    & $python -m http.server $PORT
    Write-Host ""
    Write-Host "  Server stopped."
    Write-Host "Press Enter to close..."
    Read-Host | Out-Null
    exit 0
}

# ---- Try Node.js ----
try {
    $nodeVer = & node --version 2>$null
    if ($nodeVer) {
        Write-Host "  [OK] Node.js $nodeVer found. Starting server ..." -ForegroundColor Green
        Write-Host ""
        Write-Host "  URL : $URL"
        Write-Host "  Stop: press Ctrl+C in this window"
        Write-Host ""
        Start-Process $URL
        & npx --yes serve -p $PORT -s .
        Write-Host ""
        Write-Host "  Server stopped."
        Write-Host "Press Enter to close..."
        Read-Host | Out-Null
        exit 0
    }
} catch {}

# ---- Nothing found ----
Write-Host "  =============================================" -ForegroundColor Red
Write-Host "   [ERROR] No server runtime found" -ForegroundColor Red
Write-Host "  ============================================="
Write-Host ""
Write-Host "  Install Python 3 (free, recommended):"
Write-Host "    https://www.python.org/downloads/"
Write-Host ""
Write-Host "  IMPORTANT: during install, check the box:"
Write-Host "    'Add Python to PATH'"
Write-Host ""
Write-Host "  Or install Node.js:"
Write-Host "    https://nodejs.org/"
Write-Host ""
Write-Host "  After installing, run start.bat again."
Write-Host ""
Write-Host "Press Enter to close..."
Read-Host | Out-Null
exit 1
