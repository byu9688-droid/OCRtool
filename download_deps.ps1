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

# 3. WASM core (SIMD version -- faster, supported by most modern browsers)
#    Version MUST match what tesseract.js@4 expects: tesseract.js-core@v4.0.4
$r = Download-File "Tesseract WASM core SIMD (~6 MB)" "lib\tesseract-core-simd.wasm.js" @(
    "https://cdn.jsdelivr.net/npm/tesseract.js-core@v4.0.4/tesseract-core-simd.wasm.js",
    "https://unpkg.com/tesseract.js-core@4.0.4/tesseract-core-simd.wasm.js"
)
# SIMD core is optional -- non-SIMD fallback below is sufficient
if (-not $r) {
    Write-Host "  NOTE: SIMD core unavailable -- non-SIMD version will be used instead." -ForegroundColor Yellow
    Write-Host ""
}

# 4. WASM core (non-SIMD fallback -- required)
$r = Download-File "Tesseract WASM core (~6 MB)" "lib\tesseract-core.wasm.js" @(
    "https://cdn.jsdelivr.net/npm/tesseract.js-core@v4.0.4/tesseract-core.wasm.js",
    "https://unpkg.com/tesseract.js-core@4.0.4/tesseract-core.wasm.js"
)
if (-not $r) {
    Write-Host "  NOTE: WASM core optional; OCR will attempt CDN fallback." -ForegroundColor Yellow
    Write-Host ""
}

# 5. Language data
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
