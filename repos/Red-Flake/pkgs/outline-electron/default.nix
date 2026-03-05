{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./package.nix {
  electron_39 = pkgs.electron_39;
}
