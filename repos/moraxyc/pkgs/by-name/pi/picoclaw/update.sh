#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update coreutils
# shellcheck shell=bash

set -eou pipefail

nix-update picoclaw.goModules --version=skip --override-filename pkgs/by-name/pi/picoclaw/package.nix
nix-update picoclaw.frontend.pnpmDeps --version=skip --override-filename pkgs/by-name/pi/picoclaw/package.nix
