#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v flutter >/dev/null; then echo 'Install Flutter SDK and add it to PATH.'; exit 1; fi
if [[ ! -f android/gradle/wrapper/gradle-wrapper.jar || ! -f android/gradlew || ! -f android/gradlew.bat ]]; then
  temp=$(mktemp -d); trap 'rm -rf "$temp"' EXIT
  flutter create --platforms=android --project-name tamweely --org com.tamweely --no-pub "$temp/tamweely"
  cp "$temp/tamweely/android/gradlew" "$temp/tamweely/android/gradlew.bat" android/
  cp "$temp/tamweely/android/gradle/wrapper/gradle-wrapper.jar" android/gradle/wrapper/
fi
chmod +x android/gradlew
flutter pub get
if ! grep -qi 'pdf\.js\|pdf\.min\.js\|pdfjs' web/index.html; then dart run pdfx:install_web; fi
