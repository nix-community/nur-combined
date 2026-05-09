{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; }; # functions

  ibkr-desktop = pkgs.callPackage ./pkgs/ibkr-desktop { };

  proton-meet = pkgs.callPackage ./pkgs/proton-meet { };

  trackaudio = pkgs.callPackage ./pkgs/trackaudio { };

  vatis = pkgs.callPackage ./pkgs/vatis { };
}
