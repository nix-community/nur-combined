{
  pkgs ? import <nixpkgs> { },
}:
{
  basic-memory = pkgs.callPackage ./pkgs/basic-memory { };
  fluxdown-server = pkgs.callPackage ./pkgs/fluxdown-server { };
  mnamer-rs = pkgs.callPackage ./pkgs/mnamer-rs { };
  nixosModules = {
    fluxdown = ./modules/fluxdown.nix;
  };
}
