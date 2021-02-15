#!/bin/sh
FILE=$(mktemp)
curl https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh > $FILE
chmod a+x $FILE
HASH=$(nix-hash $FILE --type sha256 --base32)
VERSION=$(curl https://download2.interactivebrokers.com/installers/tws/latest-standalone/version.json | sed 's/twslatest_callback({"buildVersion":"\(.*\)","buildDateTime.*/\1/')
echo $HASH
echo $VERSION
rm $FILE
sed -i -e 's/version = ".*/version = "'$VERSION'";/' default.nix
sed -i -e 's/sha256 = ".*/sha256 = "'$HASH'";/' default.nix
