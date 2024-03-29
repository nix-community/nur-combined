#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

install -d "${SCRIPT_DIR}/../node2nix"

# npm lockfile workaround necessary, see: https://github.com/svanderburg/node2nix/issues/312
(nix run nixpkgs#node2nix -- -18 --pkg-name nodejs_18 -e "${SCRIPT_DIR}/../node2nix/node-env.nix" -o "${SCRIPT_DIR}/../node2nix/node-packages.nix" -c "${SCRIPT_DIR}/../node2nix/default.nix" -l "${SCRIPT_DIR}/../../package-lock.json")