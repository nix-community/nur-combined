{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./package.nix {
  electron = pkgs.electron_44;
}
