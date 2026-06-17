# download_deps.ps1 - Downloads Tesseract.js local dependencies
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Set-Location $PSScriptRoot

Write-Host ""
Write-Host "  ============================================="
Write-Host "   OCR Tool - Download Dependencies"
Write-Host "  ============================================="
Write-Host ""
Write-Host "  Downloading ~40 MB of files (one-time only)."
Write-Host "  Please wait..."
Write-Host ""

# Create directories
New-Item -ItemType Directory -Force -Path "lib"      | Out-Null
New-Item -ItemType Directory -Force -Path "langdata" | Out-Null

$files = @(
    @{ url = "https://cdn.jsdelivr.net/npm/tesseract.js@4/dist/tesseract.min.js"
       dest = "lib\tesseract.min.js"
       desc = "Tesseract.js main script (~66 KB)" },
    @{ url = "https://cdn.jsdelivr.net/npm/tesseract.js@4/dist/worker.min.js"
       dest = "lib\worker.min.js"
       desc = "Tesseract.js worker script (~123 KB)" },
    @{ url = "https://cdn.jsdelivr.net/npm/tesseract.js-core@4/tesseract-core-lstm.wasm.js"
       dest = "lib\tesseract-core-lstm.wasm.js"
       desc = "Tesseract WASM core (~6 MB)" },
    @{ url = "https://tessdata.projectnaptha.com/4.0.0/jpn.traineddata.gz"
       dest = "langdata\jpn.traineddata.gz"
       desc = "Japanese language model (~13 MB)" },
    @{ url = "https://tessdata.projectnaptha.com/4.0.0/eng.traineddata.gz"
       dest = "langdata\eng.traineddata.gz"
       desc = "English language model (~12 MB)" }
)

$wc = New-Object System.Net.WebClient
$ok = $true

foreach ($f in $files) {
    Write-Host ("  [" + ($files.IndexOf($f)+1) + "/" + $files.Count + "] " + $f.desc)
    Write-Host ("        " + $f.url)
    try {
        $wc.DownloadFile($f.url, (Join-Path $PSScriptRoot $f.dest))
        $size = [math]::Round((Get-Item (Join-Path $PSScriptRoot $f.dest)).Length / 1KB)
        Write-Host ("        OK  (" + $size + " KB)") -ForegroundColor Green
    } catch {
        Write-Host ("        FAILED: " + $_.Exception.Message) -ForegroundColor Red
        $ok = $false
    }
    Write-Host ""
}

if ($ok) {
    Write-Host "  All files downloaded!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next step: run start.bat to launch the OCR tool."
} else {
    Write-Host "  Some files failed. Check your internet connection" -ForegroundColor Yellow
    Write-Host "  and run this script again."
}

Write-Host ""
Write-Host "Press Enter to close..."
Read-Host | Out-Null
