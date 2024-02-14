{ lib, ... }:

let inherit (lib.abszero.filesystem) toModuleAttr toModuleAttr' toModuleList; in

{
  imports = toModuleList ./configurations;

  flake.nixosModules = {
    xray = ./modules/services/networking/xray/default.nix;
  }
  // toModuleAttr ./modules/themes
  // toModuleAttr' ./modules/hardware
  // toModuleAttr' ./modules/profiles;
}
