#!/usr/bin/env bash

if git branch --show-current | grep -q 'main'; then
    nix flake check --accept-flake-config
fi
