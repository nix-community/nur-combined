{ global, ... }:
let
  profiles = {
    "gnome" = ./engine/gnome;
    "kde" = ./engine/kde;
    "xfce" = ./engine/xfce;
    "i3" = ./engine/i3;
  };
  inherit (global) selectedDesktopEnvironment;
in {
  imports = [
    (profiles."${selectedDesktopEnvironment}")
  ];
}
