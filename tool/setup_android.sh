#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter --version
# Generate only missing Gradle wrapper binaries from the installed Flutter SDK.
if [[ ! -f android/gradle/wrapper/gradle-wrapper.jar || ! -f android/gradlew || ! -f android/gradlew.bat ]]; then
  temp=$(mktemp -d)
  trap 'rm -rf "$temp"' EXIT
  flutter create --platforms=android --project-name tamweely --org com.tamweely --no-pub "$temp/tamweely"
  cp "$temp/tamweely/android/gradlew" "$temp/tamweely/android/gradlew.bat" android/
  cp "$temp/tamweely/android/gradle/wrapper/gradle-wrapper.jar" android/gradle/wrapper/
fi
chmod +x android/gradlew
flutter pub get
