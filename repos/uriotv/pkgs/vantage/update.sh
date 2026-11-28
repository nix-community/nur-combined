#!/usr/bin/env bash
set -euo pipefail

# Upstream publishes no tags: the package follows main, and the version is the
# commit date (0-unstable-YYYY-MM-DD). nix-update moves rev and hash together.
nix-update --flake vantage --version=branch
