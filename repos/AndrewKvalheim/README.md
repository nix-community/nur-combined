Contents:

  - [NixOS] configuration based on [`common/system.nix`](./common/system.nix)
  - [Home Manager] configuration based on [`common/user.nix`](./common/user.nix)
  - personal [package collection][nixpkgs] overlaid by [`common/packages.nix`](./common/packages.nix) and selectively exported to [NUR] via [`nur.nix`](./nur.nix)

[Home Manager]: https://github.com/nix-community/home-manager/
[NixOS]: https://nixos.org/
[nixpkgs]: https://nixos.org/manual/nixpkgs/stable/
[NUR]: https://nur.nix-community.org/
