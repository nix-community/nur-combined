# Nix flake

![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)
[![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Foluceps%2Fnixos-config)](https://garnix.io)
![state](https://img.shields.io/badge/works-on%20my%20machines-FEDFE1)
![CI state](https://github.com/oluceps/nixos-config/actions/workflows/lint.yaml/badge.svg)
![CI state](https://github.com/oluceps/nixos-config/actions/workflows/sensitive.yaml/badge.svg)  

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
