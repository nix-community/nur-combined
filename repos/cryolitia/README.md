# nur-packages

**Cryolitia's personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/cryolitia/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-cryolitia-blue.svg)](https://cryolitia.cachix.org)

## Major packages

### [MaaAssistantArknights](https://github.com/MaaAssistantArknights/MaaAssistantArknights/)

Stable release has been upstreamed in Nixpkgs, now using Github Actions to daily auto follows the newest release(including pre-release).

With Nix flake, `maa-cli` will use [rust-overlay](https://github.com/oxalica/rust-overlay)'s beta Rust toolchain to build for verification.

A daily Github Actions will build all packages and push to [cachix](https://cryolitia.cachix.org). Additional, a hydra will build all packages with `supportCUDA = true;` weekly for validate, but won't push to cachix.

- maa-assistant-arknights-nightly

- maa-cli-nightly

### Other packages

See https://nur.nix-community.org/repos/cryolitia/

## Cachix

```nix
substituters = [
  "https://cryolitia.cachix.org"
];
trusted-public-keys = [
  "cryolitia.cachix.org-1:/RUeJIs3lEUX4X/oOco/eIcysKZEMxZNjqiMgXVItQ8="
];
```
