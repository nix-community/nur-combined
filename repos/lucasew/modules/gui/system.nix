{ cfg, ... }:
let
  profiles = {
    "gnome" = ./engine/gnome.nix;
    "kde" = ./engine/kde.nix;
    "xfce" = ./engine/xfce.nix;
    "xfce_i3" = ./engine/xfce_i3.nix;
  };
in {
  imports = [
    (profiles."${cfg.selectedDesktopEnvironment}")
  ];
}
