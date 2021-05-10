#!/usr/bin/env zsh
# Script for helping with bumps and upgrades

set -euo pipefail

EMACS_OVERLAY="https://github.com/nix-community/emacs-overlay"

emacs_overlay() {
    rev=$(git ls-remote "$EMACS_OVERLAY" refs/heads/master | awk '{print $1}')
    hash=$(nix-prefetch-url --unpack "$EMACS_OVERLAY/archive/$rev.tar.gz")
    echo "Updating emacs-overlay.nix to $rev and $hash"
    sed -i "s|^  rev = .*|  rev = \"$rev\";  # updated $(date -I)|"           ~/git/graham33/nur-packages/overlays/emacs.nix
    sed -i "s|^  sha256 = .*|  sha256 = \"$hash\";|"    ~/git/graham33/nur-packages/overlays/emacs.nix
}

emacs_overlay
