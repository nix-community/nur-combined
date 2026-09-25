{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; }; # functions

  modules = {
    tunnet = ./modules/tunnet.nix; # NixOS module exposing services.tunnet
    udpxy = ./modules/udpxy.nix; # NixOS module exposing services.udpxy
  };

  cernphone = pkgs.callPackage ./pkgs/cernphone { };

  ibkr-gateway = pkgs.callPackage ./pkgs/ibkr-gateway { };

  ibkr-desktop = pkgs.callPackage ./pkgs/ibkr-desktop { };

  ibkr-tws = pkgs.callPackage ./pkgs/ibkr-tws { };

  powerctl = pkgs.callPackage ./pkgs/powerctl { };

  proton-meet = pkgs.callPackage ./pkgs/proton-meet { };

  threema-desktop = pkgs.callPackage ./pkgs/threema-desktop { };

  trackaudio = pkgs.callPackage ./pkgs/trackaudio { };

  tunnet = pkgs.callPackage ./pkgs/tunnet { };

  udpxy = pkgs.callPackage ./pkgs/udpxy { };

  vatis = pkgs.callPackage ./pkgs/vatis { };

  xpilot = pkgs.callPackage ./pkgs/xpilot { };

  xpilot-plugin = pkgs.callPackage ./pkgs/xpilot-plugin { };

  xpilot-installer = pkgs.callPackage ./pkgs/xpilot-installer { };
}
