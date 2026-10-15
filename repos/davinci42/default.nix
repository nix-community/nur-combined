{
  pkgs ? import <nixpkgs> { },
}:
{
  basic-memory = pkgs.callPackage ./pkgs/basic-memory { };
  cf = pkgs.callPackage ./pkgs/cf { };
  changedetection-io = pkgs.callPackage ./pkgs/changedetection-io { };
  fluxdown-server = pkgs.callPackage ./pkgs/fluxdown-server { };
  mnamer-rs = pkgs.callPackage ./pkgs/mnamer-rs { };
  rsshub = pkgs.callPackage ./pkgs/rsshub { };
  spotify-spotx = pkgs.callPackage ./pkgs/spotify-spotx { };
  nixosModules.fluxdown = ./modules/fluxdown.nix;
  darwinModules.nh = ./modules/nh-darwin;
}
