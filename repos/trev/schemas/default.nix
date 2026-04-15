{
  nixpkgs ? <nixpkgs>,
  lib ? nixpkgs.lib,
}:
{
  appimages = import ./appimages.nix { inherit lib; };
  images = import ./images.nix { inherit lib; };
  libs = import ./libs.nix { };
  packages = import ./packages.nix { inherit lib; };
}
