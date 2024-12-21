#!/bin/sh
cat $(nix-build --no-out-link build-readme.nix) > README.md
