{
  pkgs ? import <nixpkgs> { },
}:
{
  fluxdown-server = pkgs.callPackage ./pkgs/fluxdown-server { };
  spotify-spotx = pkgs.callPackage ./pkgs/spotify-spotx { };
  nixosModules.fluxdown = ./modules/fluxdown.nix;
}
