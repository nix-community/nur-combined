#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -d /tmp/cli-microsoft365 ]; then
  git clone https://github.com/pnp/cli-microsoft365 /tmp/cli-microsoft365
fi

install -d "${SCRIPT_DIR}/../node2nix"

# see: https://github.com/svanderburg/node2nix/issues/143#issuecomment-499056776
# for -i "${SCRIPT_DIR}/spec.json" -> not working as local npm reference to eslint-rules cannot be resolved
(cd /tmp/cli-microsoft365 \
    && git checkout v7.6.0 \
    && nix run nixpkgs#node2nix -- -18 --pkg-name nodejs_18 --development -e "${SCRIPT_DIR}/../node2nix/node-env.nix" -o "${SCRIPT_DIR}/../node2nix/node-packages.nix" -c "${SCRIPT_DIR}/../node2nix/default.nix")

echo "TODO:"
echo "Manually replace the local references to /tmp for cli-microsoft365 repo and its local eslint-rules package"

echo "DONE."