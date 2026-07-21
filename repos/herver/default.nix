{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; }; # functions

  modules = {
    udpxy = ./modules/udpxy.nix; # NixOS module exposing services.udpxy
  };

  ibkr-gateway = pkgs.callPackage ./pkgs/ibkr-gateway { };

  ibkr-desktop = pkgs.callPackage ./pkgs/ibkr-desktop { };

  powerctl = pkgs.callPackage ./pkgs/powerctl { };

  proton-meet = pkgs.callPackage ./pkgs/proton-meet { };

  trackaudio = pkgs.callPackage ./pkgs/trackaudio { };

  udpxy = pkgs.callPackage ./pkgs/udpxy { };

  vatis = pkgs.callPackage ./pkgs/vatis { };
}
