{ self }:
let
  inherit (self.common) home-manager-modules;
  inherit (self.common.home-manager-module-sets) desktop;
in desktop ++ (with home-manager-modules; [ dconf dwarf-fortress rofi ])
