#!/bin/bash
# Ignores any electron-or-metadata-specific content and builds files for AMO
# release. YOU DO NOT NEED TO BUILD THE EXTENSION WHILE DEVELOPING!
# Call this script from the tetrio plus (..) directory

set -x

rm -r ./build
mkdir ./build

process () {
  mkdir -p $(dirname "./build/$1")
  if [[ ! $1 == ./source/lib/* ]] && [ ${1: -3} == ".js" ]; then
    echo "Building $1"
    cat $1 | node ./scripts/build-firefox.js > ./build/$1
  else
    echo "Copying $1"
    cp $1 ./build/$1
  fi
}

files=$(
  find -type f \
    ! -path "./.*" \
    ! -path "./build/*" \
    ! -path "./target/*" \
    ! -path "./node_modules/*" \
    ! -path "./scripts/*" \
    ! -path "./source/electron/*" \
    ! -path "./source/bootstrap/electron/*" \
    ! -path "./tpsecore/*" \
    ! -path "./attributions.txt" \
    ! -path "./CONTRIBUTING.md" \
    ! -path "./desktop-manifest.js" \
    ! -path "./libraries.txt" \
    ! -path "./makeTPSE*" \
    ! -path "./microplus.js" \
    ! -path "./package-lock.json" \
    ! -path "./package.json" \
    ! -path "./yarn.lock"
)
for file in $files; do
  process $file
done
wait

# Replace vue with the runtime build now that everything is built
rm ./build/source/lib/vue.js
mv ./build/source/lib/vue.runtime.js ./build/source/lib/vue.js

git rev-parse --short HEAD~1 > ./build/resources/ci-commit-previous
git rev-parse --short HEAD > ./build/resources/ci-commit
cat ./build/resources/ci-commit
cat ./build/resources/ci-commit-previous
cat ./build/resources/release-commit

cd build
zip -r ../tetrioplus.xpi -9 -u ./*
