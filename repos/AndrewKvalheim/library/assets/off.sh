#!/usr/bin/env bash
set -Eeuo pipefail

[[ -n "${SUDO_USER:-}" ]] || exec sudo --prompt "[sudo ${0##*/}] password for %p: " "$0" "$@"
udo() { runuser --user "$SUDO_USER" -- "$@"; }

# Containers / virtual machines
docker system prune --force --volumes
udo podman system prune --force --volumes
udo vagrant box prune

# Channels
nix-channel --update
udo nix-channel --update

# User packages
udo home-manager expire-generations '-7 days'
udo nom-home-manager switch

# System packages
nom-nixos-rebuild boot

# Filesystem
btrfs filesystem df /
btrfs balance start --enqueue -dusage=50 -musage=50 /

poweroff
