#!/usr/bin/env bash
set -Eeuo pipefail

. use-udo

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
