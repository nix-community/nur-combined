#!/usr/bin/env bash
eval "$(nix-build --no-out-link --expr '(import ./pkgs {}).hikariii.passthru.dotnetPackage.fetch-deps')"
