{ pkgs, ... }:

{
  extpkg = pkgs.gnomeExtensions.color-picker;
  dconf = {
    name = "org/gnome/shell/extensions/color-picker";
    value = {
      color-picker-shortcut = [ "<Super>l" ];
      enable-shortcut = false;
    };
  };
}
