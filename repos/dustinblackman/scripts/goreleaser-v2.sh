#!/usr/bin/env bash

set -e

PROGDIR=$(cd "$(dirname "$0")" && pwd)

APP="$1"
VERSION="$2"
DISTFOLDER="$3"

docker pull nixos/nix:latest

cd "$DISTFOLDER"

ls "./nix/pkgs" | while read nixfile; do
	cat "./nix/pkgs/$nixfile" | grep 'tar.gz' | awk '{print $1}' | while read arch; do
		filename=$(basename "$(cat "./nix/pkgs/$nixfile" | grep "$arch" | grep 'tar.gz' | awk -F '"' '{print $2}')")
		hash=$(echo "" | docker run -i -v "$PWD:/dist" nixos/nix:latest nix-hash --flat --base32 --type sha256 "/dist/$filename")
		sd "$arch = \"0000000000000000000000000000000000000000000000000000\"" "$arch = \"$hash\"" "./nix/pkgs/$nixfile"
	done
done

cd "$PROGDIR/.."

ls "$DISTFOLDER/nix/pkgs" | while read nixfile; do
	rm -f "./pkgs/$nixfile"
	cp "$DISTFOLDER/nix/pkgs/$nixfile" ./pkgs/
done

./scripts/generate-default.sh

git add .
git commit -m "$APP $VERSION"
git push
