# # post_build.ps1

# $source = "dist"
# $releaseDest = "build/windows/x64/runner/Release/dist"
# $debugDest = "build/windows/x64/runner/Debug/dist"

# if (Test-Path $source) {
#     Write-Output "📦 Copying $source to Release and Debug folders..."

#     # Create and copy to Release folder
#     New-Item -ItemType Directory -Force -Path $releaseDest | Out-Null
#     Copy-Item -Path "$source\*" -Destination $releaseDest -Recurse -Force

#     # Create and copy to Debug folder
#     New-Item -ItemType Directory -Force -Path $debugDest | Out-Null
#     Copy-Item -Path "$source\*" -Destination $debugDest -Recurse -Force

#     Write-Output "✅ Copy complete."
# } else {
#     Write-Output "❌ Source folder '$source' not found!"
# }

$source = "dist"
$releaseDest = "build/windows/x64/runner/Release/dist"
$debugDest = "build/windows/x64/runner/Debug/dist"

if (Test-Path $source) {
    Write-Output "📦 Copying $source to Release and Debug folders..."

    # Create and copy to Release folder
    New-Item -ItemType Directory -Force -Path $releaseDest | Out-Null
    Copy-Item -Path "$source\*" -Destination $releaseDest -Recurse -Force

    # Create and copy to Debug folder
    New-Item -ItemType Directory -Force -Path $debugDest | Out-Null
    Copy-Item -Path "$source\*" -Destination $debugDest -Recurse -Force

    Write-Output "✅ Copy complete."

    # Now, run flutter in debug mode
    Write-Output "🚀 Running flutter in debug mode for Windows..."
    # Ensure Flutter is running in debug mode for Windows
    & flutter run -d windows --debug
} else {
    Write-Output "❌ Source folder '$source' not found!"
}
