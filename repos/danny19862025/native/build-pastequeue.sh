#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p target/native
${CXX:-c++} -std=c++17 -O2 -fPIC $(pkg-config --cflags Qt6Gui) \
    -I"${SPOTLIGHT_KF6_PREFIX:-/usr}/include/KF6/KGuiAddons" \
    native/pastequeue/main.cpp -o target/native/spotlight-pastequeue \
    -L"${SPOTLIGHT_KF6_PREFIX:-/usr}/lib" -lKF6GuiAddons $(pkg-config --libs Qt6Gui)
