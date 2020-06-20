{ config, pkgs, lib, ... }:

{
  imports = [
    ../internet-background
  ];
  environment.systemPackages = with pkgs; [
    albert
    lemonbar
    alock
    glava
    libnotify
    lxqt.lxqt-policykit
  ];

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
  ];
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  services.xserver.xkbOptions = "eurosign:5";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the custom Desktop Environment.
  # login manager
  services.xserver.displayManager.gdm.enable = true;
  # xfce for file managing, volume control etc.
  services.xserver.desktopManager.xfce = {
    enable = true;
    enableXfwm = false;
  };
  # samba client
  services.gvfs.enable = true;
  services.gvfs.package = lib.mkForce pkgs.gvfs;
  # openbox wm
  services.xserver.windowManager.openbox.enable = true;
  # fixes the edges issue with ulauncher
  services.compton.enable = true;
  # fetches random background
  fetchBackground = {
    enable = true;
    url = "https://source.unsplash.com/1980x1080?architecture,night";
  };
  # set default config
  services.xserver.displayManager.defaultSession = "none+openbox";
}
