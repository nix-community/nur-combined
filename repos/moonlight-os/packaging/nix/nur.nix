{
  pkgs ? import <nixpkgs> { },
}:
{
  helios = pkgs.callPackage ./package.nix { };
  nixosModules.helios = import ./module.nix;
}
