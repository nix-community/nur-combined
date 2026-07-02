{
  pkgs ? import <nixpkgs> { },
}:
{
  throne = pkgs.callPackage ./pkgs/throne { };

  teambridge = pkgs.callPackage ./pkgs/teambridge { };

  torrserver = pkgs.callPackage ./pkgs/torrserver { };

  nixosModules = import ./modules;
  homeModules = import ./hm-modules;
}
