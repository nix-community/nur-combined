#!/usr/bin/env zsh
# Script for helping with bumps and upgrades

set -euo pipefail

EMACS_OVERLAY="https://github.com/nix-community/emacs-overlay"

upgrade_emacs_overlay() {
    rev=$(git ls-remote "$EMACS_OVERLAY" refs/heads/master | awk '{print $1}')
    hash=$(nix-prefetch-url --unpack "$EMACS_OVERLAY/archive/$rev.tar.gz")
    echo "Updating emacs-overlay.nix to $rev and $hash"
    sed -i "s|^  rev = .*|  rev = \"$rev\";  # updated $(date -I)|"           ~/git/graham33/nur-packages/overlays/10-emacs.nix
    sed -i "s|^  sha256 = .*|  sha256 = \"$hash\";|"    ~/git/graham33/nur-packages/overlays/10-emacs.nix
}

upgrade_homeassistant_stubs() {
    homeassistant_version=$(nix eval -I 'nixpkgs=channel:nixos-unstable' "nixpkgs.home-assistant.version" | sed -e 's/"//g')
    echo "Version: $homeassistant_version"
    sha256=$(nix-prefetch-git --quiet https://github.com/KapJI/homeassistant-stubs $homeassistant_version | jq .sha256)
    echo "sha256: $sha256"
    sed -i pkgs/homeassistant-stubs/default.nix -e "s/version = \"[0-9\.]+\"/version = \"$homeassistant_version\"/"
    sed -i pkgs/homeassistant-stubs/default.nix -e "s/sha256 = \"[^\"\"]+\"/sha256 = $sha256/"
}

upgrade_phacc() {
    homeassistant_version=$(nix eval -I 'nixpkgs=channel:nixos-unstable' "nixpkgs.home-assistant.version" | sed -e 's/"//g')
    echo "Home Assistant version : $homeassistant_version"
    phacc_version=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/MatthewFlamm/pytest-homeassistant-custom-component/releases | jq ".[] | select(.body|test(\"$homeassistant_version\")).tag_name" | sed -e 's/"//g')
    echo "PHACC version: $phacc_version"
    sha256=$(nix-prefetch-git --quiet https://github.com/MatthewFlamm/pytest-homeassistant-custom-component $phacc_version | jq .sha256)
    echo "sha256: $sha256"
    sed -i pkgs/pytest-homeassistant-custom-component/default.nix -e "s/version = \"[0-9\.]+\"/version = \"$phacc_version\"/"
    sed -i pkgs/pytest-homeassistant-custom-component/default.nix -e "s/sha256 = \"[^\"\"]+\"/sha256 = $sha256/"
}

latest_github_release() {
    org=$1
    repo=$2
    release=$(curl -s -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/$org/$repo/releases" | jq ".[0].tag_name" | sed -e 's/"//g')
    echo $release
}

version_from_tag() {
    tag=$1
    echo $(echo $tag | sed -e 's/^v//')
}

git_sha256() {
    git_url=$1
    rev=$2
    sha256=$(nix-prefetch-git --quiet $git_url $rev | jq .sha256 | sed -e 's/"//g')
    echo $sha256
}
upgrade_github_release() {
    org=$1
    repo=$2
    release_tag=$(latest_github_release $org $repo)
    echo "$org/$repo release tag: $release_tag"
    version=$(version_from_tag $release_tag)
    echo "$org/$repo version: $version"
    sha256=$(git_sha256 https://github.com/$org/$repo $release_tag)
    echo "sha256: $sha256"
    sed -i pkgs/$repo/default.nix -e "s/version = \"[0-9\.]+\"/version = \"$version\"/"
    sed -i pkgs/$repo/default.nix -e "s/sha256 = \"[^\"\"]+\"/sha256 = $sha256/"
}

upgrade_smartbox() {
    upgrade_github_release graham33 smartbox
}

upgrade_hass_smartbox() {
    upgrade_github_release graham33 hass-smartbox
}

if [ "$#" -lt 1 ]; then
    # Don't upgrade emacs-overlay by default, for stability
    # upgrade_emacs_overlay
    upgrade_homeassistant_stubs
    upgrade_phacc
    upgrade_hass_smartbox
    upgrade_smartbox
else
    upgrade_$1
fi
