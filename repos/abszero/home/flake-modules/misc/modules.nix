{ lib, ... }:

let
  inherit (lib.abszero.filesystem) toModuleAttr toModuleAttr';
in

{
  flake.homeModules =
    toModuleAttr ../../lib/modules/themes
    // toModuleAttr' ../modules/profiles
    // toModuleAttr ../modules/themes;
}
