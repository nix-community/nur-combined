#!/usr/bin/env bash
set -eu -o pipefail

npins update

for file in pkgs/*/update.sh; do
	pushd "$(dirname "$file")"
	./update.sh
	popd
done
