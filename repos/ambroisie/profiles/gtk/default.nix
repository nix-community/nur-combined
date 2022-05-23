{ config, lib, ... }:
let
  cfg = config.my.profiles.gtk;
in
{
  options.my.profiles.gtk = with lib; {
    enable = mkEnableOption "gtk profile";
  };

  config = lib.mkIf cfg.enable {
    # Allow setting GTK configuration using home-manager
    programs.dconf.enable = true;

    # GTK theme configuration
    my.home.gtk.enable = true;
  };
}
