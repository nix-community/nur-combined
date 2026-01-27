# access-nix

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/boo15mario/access-nix/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-boo15mario-blue.svg)](https://boo15mario.cachix.org)

## Usage

### Via NUR (Nix User Repository)

If you have [NUR](https://github.com/nix-community/NUR) installed:

```bash
nix-env -iA nur.repos.boo15mario.access-launcher
```

### Via Flakes

```bash
nix profile install github:boo15mario/access-nix#access-launcher
```

or run directly:

```bash
nix run github:boo15mario/access-nix#access-launcher
```
