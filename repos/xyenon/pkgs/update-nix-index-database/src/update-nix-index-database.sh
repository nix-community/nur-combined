#!/use/bin/env sh

set -eu

filename="index-x86_64-$(uname | tr A-Z a-z)"
mkdir -p "$HOME/.cache/nix-index"
cd "$HOME/.cache/nix-index" || exit 1
# -N will only download a new version if there is an update.
wget -N "https://github.com/Mic92/nix-index-database/releases/latest/download/$filename"
ln -f "$filename" files
cd - || exit 1
