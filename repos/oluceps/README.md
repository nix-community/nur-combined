# Nix flake

[![nixos cfg](https://img.shields.io/badge/NixOS%20cfg-3A8FB7?style=for-the-badge&logo=nixos&logoColor=BBDDE5)](https://nixos.org/)
![works](https://img.shields.io/badge/works-on%20my%20machines-FEDFE1?style=for-the-badge)
[![lint status](https://img.shields.io/github/actions/workflow/status/oluceps/nixos-config/lint.yaml?branch=trival&style=for-the-badge&label=lint&color=00AA90)](https://github.com/oluceps/nixos-config/actions?query=branch%3Atrival)

NixOS configurations. ~100% config Nixfied.

with

+ [flake-parts](https://github.com/hercules-ci/flake-parts)
+ [vaultix](https://github.com/oluceps/vaultix)
+ [lanzaboote](https://github.com/nix-community/lanzaboote)
+ [preservation](https://github.com/WilliButz/preservation)
+ [disko](https://github.com/nix-community/disko)

---

### Binary Cache

```nix
nix.settings = {
  substituters = ["https://cache.garnix.io"];
  trusted-public-keys = [
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];
};
```
