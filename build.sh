#!/bin/bash
set -e

echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release

echo "Build complete!"
