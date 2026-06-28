{
  pkgs ? import <nixpkgs> { },
}:
{
  throne = pkgs.callPackage ./pkgs/throne { };

  teambridge = pkgs.callPackage ./pkgs/teambridge { };

  torrserver = pkgs.callPackage ./pkgs/torrserver { };

  nixosModules.torrserver = ./modules/torrserver/nixos.nix;
  homeModules.torrserver = ./modules/torrserver/home-manager.nix;
}
