# The big build script that does everything
# For use from CI
set -x

# load config
source ./resources/desktop-ci/config

apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install git gcc curl wget -y -qq

echo "Writing commit to resources/ci-commit and resources/ci-commit-previous..."
git rev-parse --short HEAD~1 > resources/ci-commit-previous # commit for display purposes
git rev-parse --short HEAD > resources/ci-commit # commit for display purposes
cat resources/ci-commit-previous
cat resources/ci-commit
cat resources/release-commit
git pull --recurse-submodules # ensure tpsecore is pulled in

# install rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"
rustup default 1.94.0
rustup target add wasm32-unknown-unknown

# build it
git submodule init
git submodule update
cd tpsecore
cargo build --quiet --profile release --target wasm32-unknown-unknown --features wasm_rendering
cp target/wasm32-unknown-unknown/release/tpsecore.wasm ../source/lib
cp tpsecore.js ../source/lib
cd ..

# build script dependencies
DEBIAN_FRONTEND=noninteractive apt-get install zip -y -qq

# node canvas dependencies
DEBIAN_FRONTEND=noninteractive apt-get install build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev -y -qq

# install node
apt install nodejs npm -y
node -v
npm i -g yarn

# build it
git checkout $CI_COMMIT_REF_NAME -f && git pull && git reset --hard $CI_COMMIT_SHA
echo Building version v`grep -oP "(?<=version\": \")[^\"]+(?=\")" < manifest.json`
ls -a
yarn --ignore-engines
bash ./scripts/pack-firefox.sh
bash ./scripts/pack-electron.sh
zip -r app.asar.zip -9 app.asar
TETRIO_PLUS_VERSION=$(cat ./manifest.json | node -e "console.log(JSON.parse(require('fs').readFileSync(0, 'utf-8')).version)")
cp app.asar.zip tetrio-plus_v${TETRIO_PLUS_VERSION}_for_desktop_${DESKTOP_VERSION_SHORT}.asar.zip
