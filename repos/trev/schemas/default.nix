{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  schemas ? { },
}:
{
  images = import ./images.nix { inherit pkgs schemas; };
  packages = import ./packages.nix { inherit pkgs schemas; };
}
