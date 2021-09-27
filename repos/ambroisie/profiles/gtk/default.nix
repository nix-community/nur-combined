{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.gtk;
in
{
  options.my.profiles.gtk = with lib; {
    enable = mkEnableOption "bluetooth profile";
  };

  config = lib.mkIf cfg.enable {
    # Allow setting GTK configuration using home-manager
    programs.dconf.enable = true;

    # GTK theme configuration
    my.home.gtk.enable = true;
  };
}
