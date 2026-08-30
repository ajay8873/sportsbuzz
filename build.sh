#!/bin/bash
set -e

echo "=== Installing Flutter SDK on Cloudflare Pages ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi

export PATH="$PATH:$HOME/flutter/bin"
flutter --version
flutter config --enable-web

echo "=== Building Flutter Web Release ==="
flutter build web --release

echo "=== Copying SPA Redirects ==="
cp web/_redirects build/web/_redirects 2>/dev/null || true
echo "=== Build Completed Successfully ==="
