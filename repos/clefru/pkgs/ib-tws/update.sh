#!/bin/sh
cd $(dirname $0)

URL_PREFIX=https://download2.interactivebrokers.com/installers/tws/latest-standalone
URL_JSON=${URL_PREFIX}/version.json
URL_INSTALLER=${URL_PREFIX}/tws-latest-standalone-linux-x64.sh

UPSTREAM_VERSION=$(curl ${URL_JSON} | sed 's/twslatest_callback({"buildVersion":"\(.*\)","buildDateTime.*/\1/')
LOCAL_VERSION=$(grep -Po 'version = "\K([^"]*)' default.nix)

if [ "$1" == "--no-git" ]; then
    GIT="true";
else
    GIT="git";
fi

if [ "$UPSTREAM_VERSION" != "$LOCAL_VERSION" -a -n "$UPSTREAM_VERSION" ]; then
  $GIT pull --rebase
  if [ -z "$(git status --untracked-files=no --porcelain)" ]; then
      $GIT stash
      CLEANUP="$GIT stash pop"
  fi
  FILE=$(mktemp)
  curl ${URL_INSTALLER} > $FILE
  chmod a+x $FILE
  HASH=$(nix-hash $FILE --type sha256 --base32)
  rm $FILE
  sed -i -e 's/version = ".*/version = "'$UPSTREAM_VERSION'";/' default.nix
  sed -i -e 's/sha256 = ".*/sha256 = "'$HASH'";/' default.nix
  $GIT add default.nix
  $GIT commit -m "ib-tws: $LOCAL_VERSION -> $UPSTREAM_VERSION"
  eval $CLEANUP
  $GIT push
fi
