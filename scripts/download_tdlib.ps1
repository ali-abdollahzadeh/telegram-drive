# Download precompiled TDLib Android binaries (libtdjson.so)
# Run this script ONCE before building the app.
#
# Source: https://github.com/tdlib/td (official TDLib)
# Prebuilt: community mirrors with CI-built binaries
#
# Usage:  .\scripts\download_tdlib.ps1

param(
    [string]$Version = "v1.8.29"
)

$BaseUrl = "https://github.com/danog/tdlib-binaries/releases/download/$Version"
$JniDir  = "android\app\src\main\jniLibs"

$Targets = @(
    @{ Abi = "arm64-v8a";   File = "libtdjson-arm64-v8a.so"   },
    @{ Abi = "armeabi-v7a"; File = "libtdjson-armeabi-v7a.so" },
    @{ Abi = "x86_64";      File = "libtdjson-x86_64.so"      }
)

Write-Host "Downloading TDLib $Version for Android..." -ForegroundColor Cyan

foreach ($target in $Targets) {
    $dir  = "$JniDir\$($target.Abi)"
    $dest = "$dir\libtdjson.so"
    $url  = "$BaseUrl/$($target.File)"

    New-Item -ItemType Directory -Force $dir | Out-Null

    if (Test-Path $dest) {
        Write-Host "  $($target.Abi) already present, skipping." -ForegroundColor DarkGray
        continue
    }

    Write-Host "  Downloading $($target.Abi)..." -NoNewline
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        $size = [math]::Round((Get-Item $dest).Length / 1MB, 1)
        Write-Host " OK ($size MB)" -ForegroundColor Green
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "  URL: $url" -ForegroundColor Yellow
        Write-Host "  Error: $_" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Manual alternative:" -ForegroundColor White
        Write-Host "  1. Go to https://github.com/tdlib/td/releases" -ForegroundColor White
        Write-Host "  2. Download Android prebuilt or build from source" -ForegroundColor White
        Write-Host "  3. Place libtdjson.so in android/app/src/main/jniLibs/<abi>/" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Done. You can now run: flutter run" -ForegroundColor Green
