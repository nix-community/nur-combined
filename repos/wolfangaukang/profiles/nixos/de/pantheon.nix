{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      pantheon.elementary-files
    ];
    pantheon.excludePackages = with pkgs; [
      # GNOME Browser
      epiphany
      # Email related stuff
      evolutionWithPlugins
      gnome.geary
    ];
  };
  programs.pantheon-tweaks.enable = true;
  services = {
    pantheon = {
      apps.enable = false;
      contractor.enable = true;
    };
    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "colemak";
      desktopManager.pantheon.enable = true;
      displayManager = {
        lightdm.greeters.pantheon.enable = true;
      };
    };
  };
}
