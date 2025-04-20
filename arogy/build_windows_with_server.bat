@echo off
echo 🚀 Building Windows Flutter app...
flutter build windows

echo 🛠 Running post-build script to copy app.exe to build folder...
powershell -ExecutionPolicy Bypass -File post_build.ps1

echo ✅ Build and copy completed!
pause
