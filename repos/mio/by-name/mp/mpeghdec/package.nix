{
  nixpkgs_pkgs ? { },
  callPackage,
}:
# compatibility for nixos-26.05
nixpkgs_pkgs.mpeghdec or null # (callPackage ./nixpkgs/package.nix {})
