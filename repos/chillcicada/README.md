# nurpkgs

**cc's personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/chillcicada/nurpkgs/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-chillcicada-blue.svg)](https://chillcicada.cachix.org)

Run `cachix use chillcicada` and add the public key `chillcicada.cachix.org-1:nW+OhwrpD0z5oGcBFt/aLEtzN94XcJBm81/cAHsEwVU=` to your trusted-public-keys for nixconf.

## Guide

Run `just b <target>` to build a local package for test, list all targets via `just ls`.

More recipes can be found in `justfile` or run `just`.

If you want to add a new package, add it in `pkgs/` and `default.nix`.

## LICENSE

[MIT](LICENSE)
