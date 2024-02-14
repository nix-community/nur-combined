{ lib, ... }:

let inherit (lib.abszero.filesystem) toModuleAttr toModuleAttr' toModuleList; in

{
  imports = toModuleList ./configurations;

  flake.homeModules =
    toModuleAttr ./modules/themes
    // toModuleAttr' ./modules/profiles;
}
