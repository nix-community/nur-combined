{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  schemas ? { },
}:
{
  images = import ./images.nix { inherit system pkgs schemas; };
  packages = import ./packages.nix { inherit system pkgs schemas; };
}
