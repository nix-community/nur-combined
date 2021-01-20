#!/usr/bin/env bash

set -e

PROGDIR=$(cd "$(dirname "$0")" && pwd)
cd "$PROGDIR"

REPO=$1
VERSION=$2
TARPATH=$3

./generate-pkg.sh dustinblackman "$REPO" "$VERSION" "$TARPATH"
./generate-default.sh

cd ..
git add .
git commit -m "$REPO $VERSION"
git push

