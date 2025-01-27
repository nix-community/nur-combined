{
  pkgs ? import <nixpkgs> {}
}:
{
  # my packages
  dolltags = pkgs.callPackage ./pkgs/dolltags {};
  dolltags-dev = pkgs.callPackage ./pkgs/dolltags/dev.nix {};
}
