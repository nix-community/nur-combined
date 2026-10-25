#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
# A prefix can be supplied for compile checks against an unpacked distribution SDK.
pim_prefix=${SPOTLIGHT_AKONADI_PREFIX:-/usr}
pim_headers="$pim_prefix/include/KPim6/AkonadiCore"
if [ ! -f "$pim_headers/Akonadi/ItemFetchJob" ]; then
    printf '%s\n' 'Optional Akonadi bridge: install the Akonadi 6 development headers first (see docs/PIM.md).' >&2
    exit 2
fi
mkdir -p target/native
${CXX:-c++} -std=c++17 -O2 -fPIC \
    $(pkg-config --cflags Qt6Core) \
    -I"$pim_headers" -I/usr/include/KF6/KCoreAddons \
    native/pim.cpp -o target/native/spotlight-pim \
    -L"$pim_prefix/lib" -Wl,-rpath-link,"$pim_prefix/lib" \
    -lKPim6AkonadiCore -lKF6CoreAddons $(pkg-config --libs Qt6Core)
printf '%s\n' 'Built target/native/spotlight-pim'
