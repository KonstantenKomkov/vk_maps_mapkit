#!/usr/bin/env bash
# Ставит зависимости во всех пакетах и в example.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> ."
dart pub get

PACKAGES=(
  packages/vk_maps_mapkit_platform_interface
  packages/vk_maps_api
  packages/vk_maps_mapkit_android
  packages/vk_maps_mapkit_ios
  packages/vk_maps_mapkit_web
  packages/vk_maps_mapkit
  packages/vk_maps_mapkit/example
)

for p in "${PACKAGES[@]}"; do
  echo "==> $p"
  if grep -q "sdk: flutter" "$p/pubspec.yaml"; then
    (cd "$p" && flutter pub get)
  else
    (cd "$p" && dart pub get)
  fi
done
