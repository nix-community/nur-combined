#!/usr/bin/env bash
set -euo pipefail

nix run .#helix-gj1118 -- --version
