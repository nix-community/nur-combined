{
  pkgs ? import <nixpkgs> { },
}:
{
  throne = pkgs.callPackage ./pkgs/throne { };

  teambridge = pkgs.callPackage ./pkgs/teambridge { };

  torrserver = pkgs.callPackage ./pkgs/torrserver { };

  ps5upload = pkgs.callPackage ./pkgs/ps5upload { };

  ps4-remote-pkg-sender = pkgs.callPackage ./pkgs/ps4-remote-pkg-sender { };

  nixosModules = import ./modules;
  homeModules = import ./hm-modules;
}
