#!/bin/bash
# A script for local building.
# Run as ./scripts/build-sandbox.sh
cd tpsecore
cargo build --profile release
cp target/wasm32-unknown-unknown/release/tpsecore.wasm ../source/lib
cd ..
rm -rf /tmp/tetrio-plus-build
mkdir /tmp/tetrio-plus-build
cp -r . /tmp/tetrio-plus-build

if [ ! -f 'TETR.IO Setup.tar.gz' ]; then
  wget -q -N https://tetr.io/about/desktop/builds/10/TETR.IO%20Setup.tar.gz
fi
firejail --private=/tmp/tetrio-plus-build bash ./scripts/pack-electron.sh
#firejail --private=/tmp/tetrio-plus-build bash ./scripts/pack-firefox.sh

sha256sum /tmp/tetrio-plus-build/{app.asar,tetrioplus.xpi}
ls -lh /tmp/tetrio-plus-build/{app.asar,tetrioplus.xpi}
