{ pkgs, ... }:
{
  extpkg = pkgs.gnomeExtensions.focus-changer;
  dconf = {
    name = "org/gnome/shell/extensions/focus-changer";
    value = {
      focus-left= ["<Super>Left"];
      focus-right= ["<Super>Right"];
      focus-up= ["<Super>k"];
      focus-down= ["<Super>j"];
    };
  };
}



