# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- GitHub Actions -->

[![Update flake.lock](https://github.com/definfo/nur-packages/actions/workflows/update-flake-lock.yml/badge.svg)](https://github.com/definfo/nur-packages/actions/workflows/update-flake-lock.yml)

[![Update package metadata](https://github.com/definfo/nur-packages/actions/workflows/update-packages.yml/badge.svg)](https://github.com/definfo/nur-packages/actions/workflows/update-packages.yml)

<!-- Garnix CI -->

[![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fdefinfo%2Fnur-packages)](https://garnix.io/repo/definfo/nur-packages)

## Quick Start

Add following input in `flake.nix`:

```nix
inputs.nur-definfo.url = "github:definfo/nur-packages";
```

### Installation

- NixOS configuration

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    inputs.nur-definfo.legacyPackages.${pkgs.system}.aya-prover
  ];
}
```

- Home-manager

```nix
{ pkgs, ... }:
{
  home.packages = [ inputs.nur-definfo.legacyPackages.${pkgs.system}.aya-prover ];
}
```

- Nix 3 CLI (through Nix registry)

```shell
nix profile nur-definfo#aya-prover
```
