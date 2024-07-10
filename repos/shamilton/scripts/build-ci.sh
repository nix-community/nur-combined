#!/bin/bash

cd "flakes/${CHANNEL_BRANCH}"
nix run github:Mic92/nix-fast-build -- --skip-cached --no-nom --cachix-cache "${CACHIX_CACHE}" 
