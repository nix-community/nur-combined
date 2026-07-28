# so1ve/nur-packages

Ray's personal [NUR](https://github.com/nix-community/NUR) repository

[![CI](https://github.com/so1ve/nur-packages/actions/workflows/ci.yml/badge.svg)](https://github.com/so1ve/nur-packages/actions/workflows/ci.yml)
[![Cachix Cache](https://img.shields.io/badge/cachix-so1ve-blue.svg)](https://so1ve.cachix.org)

## Packages

| Attribute | Documentation |
| --- | --- |
| `ab-download-manager` | [Usage](pkgs/ab-download-manager/README.md) |
| `r-maple-mono-nf-cn` | [Usage](pkgs/r-maple-mono-nf-cn/README.md) |
| `radmin-vpn` | [Usage](pkgs/radmin-vpn/README.md) |

## [NUR](https://github.com/nix-community/NUR)

### Package

```nix
environment.systemPackages = [
  pkgs.nur.repos.so1ve.ab-download-manager
];
```

### Home Manager module

```nix
imports = [
  inputs.nur.repos.so1ve.homeModules.ab-download-manager
];
```

## Flake

### Run or install

```bash
nix run github:so1ve/nur-packages#ab-download-manager
nix profile install github:so1ve/nur-packages#ab-download-manager
```

### Input

```nix
{
  inputs.so1ve-nur = {
    url = "github:so1ve/nur-packages";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

## Cachix

```nix
nix.settings = {
  extra-substituters = [ "https://so1ve.cachix.org" ];
  extra-trusted-public-keys = [
    "so1ve.cachix.org-1:51jcW4FkJhiLcqPsiUx3nglRP469les8F9zjFxio1nw="
  ];
};
```

## Update package sources

```bash
nix run .#update
```
