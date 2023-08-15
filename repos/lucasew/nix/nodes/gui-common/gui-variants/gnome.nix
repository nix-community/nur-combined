{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.services.xserver.desktopManager.gnome.enable {
    services = {
      xserver = {
        enable = lib.mkDefault true;
        displayManager.gdm.enable = lib.mkDefault true;
      };
    };
    environment.systemPackages = with pkgs; [
      gnomeExtensions.night-theme-switcher
      gnomeExtensions.sound-output-device-chooser
      gnomeExtensions.gsconnect
    ];
    # xdg.portal= {
    #   enable = true;
    #   gtkUsePortal = true;
    # };
  };
}
