# Call this script from the tetrio plus (..) directory as ./scripts/pack-electron.sh
set -e
set -x

# (re)load config
source ./resources/desktop-ci/config

# ensure asar is available
mkdir programs
cd programs
echo "{}" > package.json
yarn add @electron/asar@3.2.9
cd ..

if [ ! -f 'TETR.IO Setup.tar.gz' ]; then
  wget -q -N $DESKTOP_DOWNLOAD_URL
else
  echo "Using existing 'TETR.IO Setup.tar.gz'"
fi
# new in desktop v10: for some reason asar attempts to unpack into a folder called `app.asar.unpacked`, which it doesn't create but which does exist alongside the app.asar.
# no clue what it's for, but make it not fail by also extracting it along with app.asar (note the glob star at the end of app.asar)
tar --strip-components=2 -zxvf 'TETR.IO Setup.tar.gz' --wildcards 'tetrio-desktop-*/resources/app.asar*'

./programs/node_modules/@electron/asar/bin/asar.js extract app.asar out
node ./scripts/build-electron.js

mkdir -p out/tetrioplus
git archive HEAD | tar -x -C out/tetrioplus
cp app.asar out/app.asar.vanilla
rm out/tetrioplus/resources/ci-commit-previous
rm out/tetrioplus/resources/ci-commit
git rev-parse --short HEAD~1 > out/tetrioplus/resources/ci-commit-previous
git rev-parse --short HEAD > out/tetrioplus/resources/ci-commit

cd out
cp tetrioplus/resources/desktop-ci/yarn.lock .
patch package.json tetrioplus/resources/desktop-ci/package.json.diff
yarn --ignore-engines
cd ..

# note: bit of a hack, assumes we're being called from build.sh after doing the tpsecore build
cp source/lib/tpsecore.wasm source/lib/tpsecore.js out/tetrioplus/source/lib

# cleanup
rm 'TETR.IO Setup.tar.gz' app.asar

./programs/node_modules/@electron/asar/bin/asar.js pack out app.asar
