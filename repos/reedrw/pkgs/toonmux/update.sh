#!/usr/bin/env nix-shell
#! nix-shell ../../shell.nix -i bash

nix-prefetch-github JonathanHelianthicusDoe toonmux | tee source.json
