{ lib, ... }:

let
  inherit (lib.abszero.filesystem) toModuleAttr toModuleAttr' toModuleList;
in

{
  imports = toModuleList ./configurations;

  flake.homeModules =
    toModuleAttr ../lib/modules/themes
    // toModuleAttr' ./modules/profiles
    // toModuleAttr ./modules/themes;
}
