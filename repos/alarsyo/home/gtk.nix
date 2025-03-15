{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.home.gtk;
in {
  options.my.home.gtk = with lib; {
    enable = (mkEnableOption "GTK configuration") // {default = config.my.home.x.enable;};
  };

  config.gtk = lib.mkIf cfg.enable {
    enable = true;

    font = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };

    gtk2 = {
      # No garbage polluting my $HOME
      #
      # I had this enabled but some program somehow couldn't find my
      # configuration there. I think it was nm-applet.
      #
      #configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };

    iconTheme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita";
    };

    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita";
    };
  };
}
