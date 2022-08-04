{pkgs, config, ... }:
{
  services = {
    xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        gnome3.enable = true;
      };
      displayManager.gdm.enable = true;
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
}
