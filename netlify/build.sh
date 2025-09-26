#!/usr/bin/env bash
set -e

git clone https://github.com/flutter/flutter.git -b ${FLUTTER_CHANNEL:-stable} --depth 1 $HOME/flutter
export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter pub get

unset FLUTTER_WEB_RENDERER

flutter build web --release --pwa-strategy=none