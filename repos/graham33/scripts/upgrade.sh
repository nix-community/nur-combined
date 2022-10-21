#!/usr/bin/env nix-shell
#! nix-shell -i zsh -p pkgs.git pkgs.semver-tool
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
    org="KapJI"
    repo="homeassistant-stubs"
    homeassistant_version=$(nix eval -I 'nixpkgs=channel:nixos-unstable' "nixpkgs#home-assistant.version" | sed -e 's/"//g')
    version=$homeassistant_version
    sha256=$(nix-prefetch-git --quiet https://github.com/$org/$repo $homeassistant_version | jq .sha256)
    echo "$org/$repo: version=$version, sha256=$sha256 (homeassistant-version=$homeassistant_version)"
    sed -i pkgs/$repo/default.nix -e "s/version = \"[0-9\.]*\"/version = \"$homeassistant_version\"/"
    sed -i pkgs/$repo/default.nix -e "s/sha256 = \"[^\"]*\"/sha256 = $sha256/"
}

upgrade_phacc() {
    org="MatthewFlamm"
    repo="pytest-homeassistant-custom-component"
    homeassistant_version=$(nix eval -I 'nixpkgs=channel:nixos-unstable' "nixpkgs#home-assistant.version" | sed -e 's/"//g')
    version=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$org/$repo/releases | jq ".[] | select(.body|test(\"$homeassistant_version\")).tag_name" | sed -e 's/"//g' | head -1)
    sha256=$(nix-prefetch-git --quiet https://github.com/$org/$repo $version | jq .sha256)
    echo "$org/$repo: version=$version, sha256=$sha256 (homeassistant-version=$homeassistant_version)"
    sed -i pkgs/$repo/default.nix -e "s/version = \"[0-9\.]*\"/version = \"$version\"/"
    sed -i pkgs/$repo/default.nix -e "s/sha256 = \"[^\"]*\"/sha256 = $sha256/"
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

git_prefetch() {
    git_url=$1
    rev=$2
    field=$3
    val=$(nix-prefetch-git --quiet $git_url $rev | jq .$field | sed -e 's/"//g')
    echo $val
}

upgrade_github_release() {
    org=$1
    repo=$2
    if [ "$#" -gt 2 ]; then
        ref=$3
        latest_release_tag=$(latest_github_release $org $repo)
        latest_version=$(version_from_tag $latest_release_tag)
        new_minor_version=$(semver bump minor $latest_version)
        pre_release_version=$(semver bump prerel pre $new_minor_version)
        rev=$(git_prefetch https://github.com/$org/$repo $ref rev)
        version=$(semver bump build ${rev:0:6} $pre_release_version)
    else
        release_tag=$(latest_github_release $org $repo)
        rev=$release_tag
        version=$(version_from_tag $release_tag)
        current_version=$(sed pkgs/$repo/default.nix -n -e "s/^ *version = \"\([^\"]*\)\".*$/\1/p")
        if [ $(semver compare $version $current_version) -lt 0 ]; then
            echo "Not upgrading $org/$repo automatically since current version $current_version is newer than latest release $version"
            return
        fi
    fi
    sha256=$(git_prefetch https://github.com/$org/$repo $rev sha256)
    echo "$org/$repo: version=$version, rev=$rev, sha256=$sha256"
    sed -i pkgs/$repo/default.nix -e "s/version = \"[^\"]*\"/version = \"$version\"/"
    sed -i pkgs/$repo/default.nix -e "s/sha256 = \"[^\"]*\"/sha256 = \"$sha256\"/"
    # use version in rev if possible
    rev=$(echo $rev | sed -e "s/^v$version$/v\${version}/")
    sed -i pkgs/$repo/default.nix -e "s/rev = \"[^\"]*\"/rev = \"$rev\"/"
}

upgrade_smartbox() {
    if [ "$#" -gt 0 ]; then
        upgrade_github_release graham33 smartbox $1
    else
        upgrade_github_release graham33 smartbox
    fi
}

upgrade_hass_smartbox() {
    if [ "$#" -gt 0 ]; then
        upgrade_github_release graham33 hass-smartbox $1
    else
        upgrade_github_release graham33 hass-smartbox
    fi
}

if [ "$#" -lt 1 ]; then
    # Don't upgrade emacs-overlay by default, for stability
    # upgrade_emacs_overlay
    upgrade_homeassistant_stubs
    upgrade_phacc
    upgrade_hass_smartbox
    upgrade_smartbox
else
    if [ "$#" -gt 1 ]; then
        # User supplied a ref
        upgrade_$1 $2
    else
        upgrade_$1
    fi
fi
