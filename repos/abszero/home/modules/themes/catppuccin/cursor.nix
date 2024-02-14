{ config, pkgs, ... }:

let
  inherit (builtins) getAttr;
  inherit (config.lib.catppuccin) getVariant toTitleCase;
in

{
  imports = [ ./_options.nix ];

  home.pointerCursor = {
    package = getAttr (getVariant + "Light") pkgs.catppuccin-cursors;
    name = "Catppuccin-${toTitleCase getVariant}-Light";
    gtk.enable = true;
    x11.enable = true;
  };
}
