#!/bin/bash
trap "echo; exit" INT
set -e

# 1. Detect if Nix is installed
if ! command -v nix &> /dev/null; then
    echo "[!] Nix is not installed."
    echo "[+] Installing via Determinate Systems..."
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --prefer-upstream-nix
    
    echo "[OK] Nix installed."
    echo "[!] Please close this terminal and open a new one to load Nix into your path."
    echo "    Then, run this script again."
    exit 0
fi

# 2. Go to the script directory
pushd "$(dirname "$0")" > /dev/null

# 3. Determine the target configuration

# DEBUG: Show what the script sees. 
# We use ':-<unset>' to print "<unset>" if the variable is empty.
echo "[*] \$HOST variable set to '${HOST:-<unset>}'"

# Logic:
# 1. Try $HOST (from user env, must be exported)
# 2. Try $HOSTNAME (bash default)
# 3. Fallback to 'apple-seeds'
TARGET="${HOST:-${HOSTNAME:-apple-seeds}}"

# Strip .local from hostname if present (macOS adds this sometimes)
TARGET=${TARGET%.local}

echo "[*] Building configuration for: .#$TARGET"

# 4. Check for darwin-rebuild presence
if command -v darwin-rebuild &> /dev/null; then
    sudo darwin-rebuild switch --flake ".#$TARGET"
else
    echo "[>] darwin-rebuild not found, bootstrapping..."
    sudo nix run --extra-experimental-features "nix-command flakes" nix-darwin -- switch --flake ".#$TARGET"
fi

popd > /dev/null
echo "[OK] Done!"
