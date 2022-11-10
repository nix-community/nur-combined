{ pkgsStatic
, ...
}:

# https://github.com/NixOS/nixpkgs/pull/160802
pkgsStatic.callPackage ./qemu.nix { }
