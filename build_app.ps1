# Dogar Dairy - Full Build & Package Script (APK + Web PWA)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Dogar Dairy - Build & Package Script   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Step 1: Build Android Release APK (split-per-abi)
Write-Host "`n[1/3] Building Android Release APK (split-per-abi)..." -ForegroundColor Yellow
flutter build apk --release --split-per-abi
if ($LASTEXITCODE -ne 0) {
    Write-Host "Android APK build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Step 2: Ensure web/downloads exists and copy app-arm64-v8a-release.apk
Write-Host "`n[2/3] Copying arm64-v8a APK to web/downloads/dogar-dairy.apk..." -ForegroundColor Yellow
if (-not (Test-Path "web\downloads")) {
    New-Item -ItemType Directory -Path "web\downloads" -Force | Out-Null
}

$apkSource = "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
if (Test-Path $apkSource) {
    Copy-Item $apkSource "web\downloads\dogar-dairy.apk" -Force
    $apkSize = (Get-Item "web\downloads\dogar-dairy.apk").Length / 1MB
    Write-Host ("Copied successfully! APK size: {0:N2} MB" -f $apkSize) -ForegroundColor Green
}
else {
    Write-Host "Warning: $apkSource not found!" -ForegroundColor Red
}

# Step 3: Build Web release bundle
Write-Host "`n[3/3] Building Flutter Web with PWA..." -ForegroundColor Yellow
flutter build web --release --pwa-strategy=offline-first
if ($LASTEXITCODE -ne 0) {
    Write-Host "Web build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Ensure APK is in build/web/downloads
if (-not (Test-Path "build\web\downloads")) {
    New-Item -ItemType Directory -Path "build\web\downloads" -Force | Out-Null
}
if (Test-Path "web\downloads\dogar-dairy.apk") {
    Copy-Item "web\downloads\dogar-dairy.apk" "build\web\downloads\dogar-dairy.apk" -Force
}

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host " SUCCESS! Web PWA and Android APK are generated and ready:" -ForegroundColor Green
Write-Host " - Web Build: build\web\" -ForegroundColor White
Write-Host " - Web APK:   web\downloads\dogar-dairy.apk" -ForegroundColor White
Write-Host " - URL Path:  /downloads/dogar-dairy.apk" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Green
