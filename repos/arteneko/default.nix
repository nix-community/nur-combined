{
  pkgs ? import <nixpkgs> {}
}:
{
  # my packages
  dolltags = pkgs.callPackage ./pkgs/dolltags {};
}
