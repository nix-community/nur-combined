# swift (Swift 6.3.3)

This is a tracking package for [Nixpkgs PR #565702](https://github.com/NixOS/nixpkgs/pull/565702), which updates Swift to 6.3.3.

It replaces the previous `swift6-jen20` hack by simply fetching the `swift-6.3-update` branch from `reckenrode/nixpkgs` as a tarball, importing it, and extracting the Swift toolchain.

## Usage

```nix
nur.repos.mio.swift
```
