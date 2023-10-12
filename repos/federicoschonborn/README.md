# NUR Packages

[![Built with Nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://nixos.org/)
[![Build and Populate Cache](https://github.com/FedericoSchonborn/nur-packages/actions/workflows/main.yaml/badge.svg)](https://github.com/FedericoSchonborn/nur-packages/actions/workflows/main.yaml)
[![Cachix Cache](https://img.shields.io/badge/cachix-federicoschonborn-blue.svg)](https://federicoschonborn.cachix.org)

My personal [NUR](https://github.com/nix-community/NUR) repository.

## Cache

This repository uses GitHub Actions to build and push all packages to a cache
provided by Cachix and is currently available for the following platforms:

```mermaid
flowchart
    subgraph "Linux (x86_64 and AArch64)"
        direction LR
        nixpkgs-unstable-linux("Nixpkgs Unstable") --> nixos-unstable-small-linux("NixOS Unstable (Small)") --> nixos-unstable-linux("NixOS Unstable") --> nixos-stable-small-linux("NixOS 23.05 (Small)") --> nixos-stable-linux("NixOS 23.05")
    end

    subgraph "Darwin (x86_64)"
        direction LR
        nixpkgs-unstable-darwin("Nixpkgs Unstable") --> nixpkgs-stable-darwin("Nixpkgs 23.05")
    end
```
