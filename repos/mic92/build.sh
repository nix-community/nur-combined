#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-output-monitor

nom-build --option keep-going true non-broken.nix --no-out-link
