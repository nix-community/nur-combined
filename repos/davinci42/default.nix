{
  pkgs ? import <nixpkgs> { },
}:
{
  changedetection-io = pkgs.callPackage ./pkgs/changedetection-io { };
  fluxdown-server = pkgs.callPackage ./pkgs/fluxdown-server { };
  rsshub = pkgs.callPackage ./pkgs/rsshub { };
  spotify-spotx = pkgs.callPackage ./pkgs/spotify-spotx { };
  nixosModules.fluxdown = ./modules/fluxdown.nix;
}
