#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -d /tmp/dashlane-cli ]; then
  git clone https://github.com/Dashlane/dashlane-cli /tmp/dashlane-cli
fi

(cd /tmp/dashlane-cli && nix run nixpkgs#node2nix -- -18 --pkg-name nodejs_18 --development -e "${SCRIPT_DIR}/../node2nix/node-env.nix" -o "${SCRIPT_DIR}/../node2nix/node-packages.nix" -c "${SCRIPT_DIR}/../node2nix/default.nix")

echo "Note: You must merge the following into the node-packages.nix file's args manually:"
cat <<EOF
    src = fetchFromGitHub {
        owner = "Dashlane";
        repo = "dashlane-cli";
        rev = "28fd4ec19c79738aa75acb8672cdd1691f8a7465";
        hash = "sha256-HiuRzcEI+6oP9oaOTxgUK41a1ajZBvAnE/bVCnzIDk0=";
    };
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
EOF

echo "Pass the following to node-packages.nix in default.nix import:"
cat <<EOF
    fetchFromGitHub
EOF

echo "Also add the following to the import expression at the top of the file in node-packages.nix:"
cat <<EOF
    fetchFromGitHub
EOF