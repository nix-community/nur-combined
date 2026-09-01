#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p git -p nix -p nix-update
# shellcheck shell=bash
# The GitHub releases atom feed only lists the ~10 most recent releases,
# which upstream fills with unrelated ext-*/agent-server/claw-server tags;
# filter the full tag list instead so nix-update doesn't fail on the feed.
NEW_VERSION=$(
  git ls-remote --tags https://github.com/browseros-ai/BrowserOS |
    sed -n 's#.*refs/tags/v\([0-9.]*\)$#\1#p' |
    sort -V | tail -1
)
[ "$NEW_VERSION" = "$UPDATE_NIX_OLD_VERSION" ] && exit 0
exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"
