# access-nix

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/boo15mario/access-nix/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-access-nix-blue.svg)](https://access-nix.cachix.org)

## Usage via nix-channel

```bash
nix-channel --add https://github.com/boo15mario/access-nix/archive/nix-channel.tar.gz access-nix
nix-channel --update
nix-env -iA access-nix.access-launcher
```

## Remove the channel

```bash
nix-channel --remove access-nix
nix-channel --update
```
