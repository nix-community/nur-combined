#!/bin/sh
UPSTREAM_VERSION=$(curl https://download2.interactivebrokers.com/installers/tws/latest-standalone/version.json | sed 's/twslatest_callback({"buildVersion":"\(.*\)","buildDateTime.*/\1/')
LOCAL_VERSION=$(grep -Po 'version = "\K([^"]*)' default.nix)

if [ "$UPSTREAM_VERSION" != "$LOCAL_VERSION" ]; then
  FILE=$(mktemp)
  curl https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh > $FILE
  chmod a+x $FILE
  HASH=$(nix-hash $FILE --type sha256 --base32)
  rm $FILE
  sed -i -e 's/version = ".*/version = "'$UPSTREAM_VERSION'";/' default.nix
  sed -i -e 's/sha256 = ".*/sha256 = "'$HASH'";/' default.nix
fi
