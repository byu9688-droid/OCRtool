# download_deps.ps1 - Downloads Tesseract.js local dependencies
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Set-Location $PSScriptRoot

Write-Host ""
Write-Host "  ============================================="
Write-Host "   OCR Tool - Download Dependencies"
Write-Host "  ============================================="
Write-Host ""
Write-Host "  Downloading ~46 MB of files (one-time only)."
Write-Host "  Please wait..."
Write-Host ""

# Create directories
New-Item -ItemType Directory -Force -Path "lib"      | Out-Null
New-Item -ItemType Directory -Force -Path "langdata" | Out-Null

$wc = New-Object System.Net.WebClient
$ok = $true

function Download-File($desc, $dest, $urls) {
    Write-Host ("  " + $desc)
    $destPath = Join-Path $PSScriptRoot $dest
    foreach ($url in $urls) {
        Write-Host ("        " + $url)
        try {
            $wc.DownloadFile($url, $destPath)
            $size = [math]::Round((Get-Item $destPath).Length / 1KB)
            Write-Host ("        OK  (" + $size + " KB)") -ForegroundColor Green
            Write-Host ""
            return $true
        } catch {
            Write-Host ("        failed: " + $_.Exception.Message) -ForegroundColor Yellow
        }
    }
    Write-Host ("        FAILED -- could not download from any URL") -ForegroundColor Red
    Write-Host ""
    return $false
}

# 1. Tesseract.js main script
$r = Download-File "Tesseract.js main script (~66 KB)" "lib\tesseract.min.js" @(
    "https://cdn.jsdelivr.net/npm/tesseract.js@4/dist/tesseract.min.js",
    "https://unpkg.com/tesseract.js@4/dist/tesseract.min.js"
)
if (-not $r) { $ok = $false }

# 2. Worker script
$r = Download-File "Tesseract.js worker script (~123 KB)" "lib\worker.min.js" @(
    "https://cdn.jsdelivr.net/npm/tesseract.js@4/dist/worker.min.js",
    "https://unpkg.com/tesseract.js@4/dist/worker.min.js"
)
if (-not $r) { $ok = $false }

# 3. WASM core -- extract correct URL from worker.min.js if it was downloaded
$wasmUrls = @(
    "https://cdn.jsdelivr.net/npm/tesseract.js-core@4.0.0/tesseract-core-lstm.wasm.js",
    "https://cdn.jsdelivr.net/npm/tesseract.js-core@4.0.4/tesseract-core-lstm.wasm.js",
    "https://cdn.jsdelivr.net/npm/tesseract.js-core@4/tesseract-core-lstm.wasm.js",
    "https://unpkg.com/tesseract.js-core@4.0.0/tesseract-core-lstm.wasm.js",
    "https://unpkg.com/tesseract.js-core@4/tesseract-core-lstm.wasm.js"
)

# Try to extract the actual WASM URL from the downloaded worker.min.js
$workerPath = Join-Path $PSScriptRoot "lib\worker.min.js"
if (Test-Path $workerPath) {
    $workerContent = Get-Content $workerPath -Raw -ErrorAction SilentlyContinue
    if ($workerContent) {
        $match = [regex]::Match($workerContent, 'https?://[^"'' ]+tesseract-core[^"'' ]*\.wasm\.js')
        if ($match.Success) {
            $extractedUrl = $match.Value
            Write-Host ("  Detected WASM URL from worker: " + $extractedUrl) -ForegroundColor Cyan
            # Put extracted URL at front of list
            $wasmUrls = @($extractedUrl) + ($wasmUrls | Where-Object { $_ -ne $extractedUrl })
        }
    }
}

$r = Download-File "Tesseract WASM core (~6 MB)" "lib\tesseract-core-lstm.wasm.js" $wasmUrls
if (-not $r) {
    Write-Host "  NOTE: WASM core is optional. OCR may still work via CDN fallback." -ForegroundColor Yellow
    Write-Host ""
}

# 4. Language data
$r = Download-File "Japanese language model (~13 MB)" "langdata\jpn.traineddata.gz" @(
    "https://tessdata.projectnaptha.com/4.0.0/jpn.traineddata.gz"
)
if (-not $r) { $ok = $false }

$r = Download-File "English language model (~12 MB)" "langdata\eng.traineddata.gz" @(
    "https://tessdata.projectnaptha.com/4.0.0/eng.traineddata.gz"
)
if (-not $r) { $ok = $false }

if ($ok) {
    Write-Host "  All essential files downloaded!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next step: run start.bat to launch the OCR tool."
} else {
    Write-Host "  Some files failed. Check your internet connection" -ForegroundColor Yellow
    Write-Host "  and run this script again."
}

Write-Host ""
Write-Host "Press Enter to close..."
Read-Host | Out-Null
