{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.gtk;
in
{
  options.my.home.gtk = with lib; {
    enable = mkEnableOption "GTK configuration";
  };

  config.gtk = lib.mkIf cfg.enable {
    enable = true;

    font = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };

    gtk2 = {
      # That sweet, sweet clean home that I am always aiming for...
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };

    iconTheme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita";
    };

    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita";
    };
  };
}
