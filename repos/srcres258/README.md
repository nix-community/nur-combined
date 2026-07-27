# srcres258's NUR repository

This is my own [NUR](https://github.com/nix-community/NUR) repository for uploading personal software packages.

iEDA is available as `ieda` on `x86_64-linux` only:

```bash
nix build github:srcres258/nur-packages#ieda
nix-build -A ieda
```

NixOS flake usage:

```nix
inputs.nur-srcres258.url = "github:srcres258/nur-packages";

environment.systemPackages = [
  inputs.nur-srcres258.packages.${pkgs.system}.ieda
];
```

![Build and populate cache](https://github.com/srcres258/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-nur--packages--srcres258-blue.svg)](https://nur-packages-srcres258.cachix.org)
