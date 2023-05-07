#!/usr/bin/env bash

nix run git+https://git.sr.ht/~rycee/mozilla-addons-to-nix -- addons.json packages.nix
