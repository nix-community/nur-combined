{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./package.nix {
  electron_39-bin = pkgs.electron_39-bin;
}
