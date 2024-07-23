{ lib, ... }:

let
  inherit (lib.abszero.filesystem) toModuleAttr toModuleAttr' toModuleList;
in

{
  imports = toModuleList ./configurations;

  flake.nixosModules =
    toModuleAttr ../lib/modules/themes
    // toModuleAttr' ./modules/profiles
    // toModuleAttr' ./modules/hardware
    // toModuleAttr ./modules/themes
    // {
      xray = ./modules/services/networking/xray/default.nix;
    };
}
