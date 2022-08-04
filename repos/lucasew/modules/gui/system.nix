{ global, ... }:
let
  profiles = {
    "gnome" = ./engine/gnome;
    "kde" = ./engine/kde;
    "xfce" = ./engine/xfce;
    "xfce_i3" = ./engine/xfce_i3;
  };
  inherit (global) selectedDesktopEnvironment;
in {
  imports = [
    (profiles."${selectedDesktopEnvironment}")
  ];
}
