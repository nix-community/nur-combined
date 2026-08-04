#!/usr/bin/env bash
set -Eeuo pipefail

[[ -n "${SUDO_USER:-}" ]] || exec sudo --prompt "[sudo ${0##*/}] password for %p: " "$0" "$@"
udo() { runuser --user "$SUDO_USER" -- env XDG_RUNTIME_DIR="/run/user/$SUDO_UID" "$@"; }

# Ephemeral data
docker system prune --force --volumes
udo podman system prune --force --volumes
udo vagrant box prune

# Nix channels
nix-channel --update
udo nix-channel --update

# Nix profiles
udo nom-home-manager switch
nom-nixos-rebuild boot

# Nix garbage collection
udo home-manager expire-generations '-7 days'
udo systemctl --user --verbose start 'nix-gc.service'
systemctl --verbose start 'nix-gc.service'

# Filesystem
btrfs filesystem df '/'
btrfs balance start --enqueue -dusage='50' -musage='50' '/'

poweroff
