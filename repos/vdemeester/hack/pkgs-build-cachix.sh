#!/usr/bin/env bash
set -e

nix-build --no-out-link . | cachix push shortbrain

