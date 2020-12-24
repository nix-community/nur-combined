# nur-packages

![Build and populate cache](https://github.com/06kellyjac/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-j--k--nur-blue.svg)](https://j-k-nur.cachix.org)

My personal [NUR](https://github.com/nix-community/NUR) repository.

It provides a pre-compiled binary cache for NixOS unstable.
To use it add the following line to your nix.conf

```
trusted-public-keys = j-k-nur.cachix.org-1:mRQf8TcRLbjJtIvdZWmnUDQ2jRlw1WE3zQuWBh9+iT8=
```

---

Packages in this repo will be ones I think don't fit in https://github.com/nixos/nixpkgs or aren't merged in yet.
They will generally be versioned but some will be on commit SHAs where there hasn't been a tag in a while.
Once a package is merged into nixpkgs I'll update it here until it's in NixOS unstable.
