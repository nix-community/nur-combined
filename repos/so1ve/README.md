# so1ve/nur-packages

Ray's personal [NUR](https://github.com/nix-community/NUR) repository

[![CI](https://github.com/so1ve/nur-packages/actions/workflows/ci.yml/badge.svg)](https://github.com/so1ve/nur-packages/actions/workflows/ci.yml)
[![Cachix Cache](https://img.shields.io/badge/cachix-so1ve-blue.svg)](https://so1ve.cachix.org)

## NUR

After enabling NUR, install a package through its repository attribute:

```nix
environment.systemPackages = [
  pkgs.nur.repos.so1ve.ab-download-manager
];
```

Published Home Manager modules are available through
`inputs.nur.repos.so1ve.homeModules` when NUR is used as a flake input.

## Flake

Run or install a package directly:

```bash
nix run github:so1ve/nur-packages#ab-download-manager
nix profile install github:so1ve/nur-packages#ab-download-manager
```

Or add the repository as a flake input:

```nix
{
  inputs.so1ve-nur = {
    url = "github:so1ve/nur-packages";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Packages are exposed through `packages` and modules through `homeModules`.

## Binary cache

```nix
nix.settings = {
  extra-substituters = [ "https://so1ve.cachix.org" ];
  extra-trusted-public-keys = [
    "so1ve.cachix.org-1:51jcW4FkJhiLcqPsiUx3nglRP469les8F9zjFxio1nw="
  ];
};
```

## Updating

```bash
nix run .#update
```

## Packages

| Attribute | Documentation |
| --- | --- |
| `ab-download-manager` | [Usage](pkgs/ab-download-manager/README.md) |
| `r-maple-mono-nf-cn` | [Usage](pkgs/r-maple-mono-nf-cn/README.md) |
