{
  nixpkgs ? <nixpkgs>,
  lib ? nixpkgs.lib,
}:
{
  images = import ./images.nix { inherit lib; };
  libs = import ./libs.nix { };
  packages = import ./packages.nix { inherit lib; };
}
