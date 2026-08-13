#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update
# shellcheck shell=bash

set -euo pipefail

nix-update deepseek-harness.pnpmDeps --version=skip
