default: (local "test")

# Fast, no-sudo validation: evaluate the `local` config and print what would
# be built. Use this instead of `just` to verify changes without a password or
# system activation. Requires new files to be `git add`ed first (Nix can't see
# untracked paths — the dry-run will name the untracked path if so).
check: check-ascii
  nix build .#nixosConfigurations.local.config.system.build.toplevel --dry-run

# Build the `local` system closure to ./result without activating (no sudo).
build:
  nix build .#nixosConfigurations.local.config.system.build.toplevel

local goal="switch" *FLAGS="":
  sudo nixos-rebuild {{goal}} --flake .#local {{FLAGS}}

rollback:
  sudo nixos-rebuild test --flake .#local --rollback

iso:
  nix build .#nixosConfigurations.installer.config.system.build.isoImage

update:
  nix flake update
  nix-update CloudflareSpeedTest --flake
  nix-update pw-duck --flake

# Check for Chinese characters in Nix files (code must be English only, no Chinese)
check-ascii:
  #!/usr/bin/env bash
  set -euo pipefail
  if grep -r -P -n '[\x{4e00}-\x{9fff}\x{3400}-\x{4dbf}\x{20000}-\x{2a6df}\x{2a700}-\x{2b73f}\x{2b740}-\x{2b81f}\x{2b820}-\x{2ceaf}\x{f900}-\x{faff}]' --include='*.nix' modules/ justfile 2>/dev/null; then \
    echo "error: Chinese characters found (code must be English only, no Chinese)" >&2; \
    exit 1; \
  fi
  echo "ASCII check passed."
