#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p target/native
${CXX:-c++} -std=c++17 -O2 -fPIC $(pkg-config --cflags Qt6Core libical) \
    native/freebusy.cpp -o target/native/spotlight-freebusy $(pkg-config --libs Qt6Core libical)
printf '%s\n' 'Built target/native/spotlight-freebusy'
