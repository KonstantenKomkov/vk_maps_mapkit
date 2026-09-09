#!/usr/bin/env bash
# Полная проверка репозитория: формат, анализ, тесты.
# Порядок пакетов — от базовых к зависимым, чтобы падение было ближе к причине.
set -euo pipefail
cd "$(dirname "$0")/.."

PACKAGES=(
  packages/vk_maps_mapkit_platform_interface
  packages/vk_maps_api
  packages/vk_maps_mapkit_android
  packages/vk_maps_mapkit_ios
  packages/vk_maps_mapkit_web
  packages/vk_maps_mapkit
)

fail=0

echo "==================== версии нативного SDK ===================="
./tool/check_sdk_versions.sh || fail=1

for p in "${PACKAGES[@]}"; do
  echo
  echo "==================== $p ===================="
  is_flutter=0
  grep -q "sdk: flutter" "$p/pubspec.yaml" && is_flutter=1

  echo "--- format ---"
  dart format --output=none --set-exit-if-changed "$p" || fail=1

  echo "--- analyze ---"
  if [ "$is_flutter" = 1 ]; then
    (cd "$p" && flutter analyze --fatal-infos) || fail=1
  else
    (cd "$p" && dart analyze --fatal-infos) || fail=1
  fi

  if [ -d "$p/test" ] && [ -n "$(find "$p/test" -name '*_test.dart' -print -quit)" ]; then
    echo "--- test ---"
    if [ "$is_flutter" = 1 ]; then
      (cd "$p" && flutter test -r github) || fail=1
    else
      (cd "$p" && dart test -r github) || fail=1
    fi

    # Часть кода ведёт себя в браузере иначе, чем на виртуальной машине:
    # целые числа там 32-битные, а проверки типов работают по-своему.
    # Пакеты, которые доезжают до браузера, поэтому проверяются и там.
    case "$p" in
      packages/vk_maps_mapkit_web|packages/vk_maps_api)
        if [ -n "${CHROME_EXECUTABLE:-}" ] || command -v google-chrome >/dev/null 2>&1 \
           || command -v chromium >/dev/null 2>&1 \
           || [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
          echo "--- test в браузере ---"
          if [ "$is_flutter" = 1 ]; then
            (cd "$p" && flutter test --platform chrome -r github) || fail=1
          else
            (cd "$p" && dart test -p chrome -r github) || fail=1
          fi
        else
          echo "--- test в браузере: Chrome не найден, пропуск ---"
        fi
        ;;
    esac
  else
    echo "--- test: нет тестов, пропуск ---"
  fi
done

echo
[ "$fail" = 0 ] && echo "check.sh: всё зелёное" || echo "check.sh: есть падения"
exit $fail
