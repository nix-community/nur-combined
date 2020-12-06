#!/usr/bin/env bash
set -eu -o pipefail

niv update

for file in pkgs/*/update.sh; do
	pushd "$(dirname "$file")"
	./update.sh
	popd
done

nix-build --no-out-link tests/overlays.nix
