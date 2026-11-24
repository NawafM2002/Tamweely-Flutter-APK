$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
function Run-Checked { param([scriptblock]$Command) & $Command; if ($LASTEXITCODE -ne 0) { throw "Command failed: $Command" } }
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw 'Install Flutter SDK and add it to PATH.' }
if (!(Test-Path 'android/gradle/wrapper/gradle-wrapper.jar') -or !(Test-Path 'android/gradlew') -or !(Test-Path 'android/gradlew.bat')) {
  $temp = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
  try {
    $project = Join-Path $temp 'tamweely'
    Run-Checked { flutter create --platforms=android --project-name tamweely --org com.tamweely --no-pub $project }
    Copy-Item (Join-Path $project 'android/gradlew') 'android/'
    Copy-Item (Join-Path $project 'android/gradlew.bat') 'android/'
    Copy-Item (Join-Path $project 'android/gradle/wrapper/gradle-wrapper.jar') 'android/gradle/wrapper/'
  } finally { if(Test-Path $temp) { Remove-Item $temp -Recurse -Force } }
}
Run-Checked { flutter pub get }
if (!(Select-String -Path 'web/index.html' -Pattern 'pdf\.js|pdf\.min\.js|pdfjs' -Quiet)) { Run-Checked { dart run pdfx:install_web } }
