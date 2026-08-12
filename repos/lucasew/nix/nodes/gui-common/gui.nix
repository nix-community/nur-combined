{ pkgs, ... }:
{
  services.xserver = {
    desktopManager.xterm.enable = false;
  };

  environment.systemPackages = with pkgs; [
    adw-gtk3  # Tema GTK3/GTK4 compatível com libadwaita
    libsForQt5.qt5ct  # Qt5 configuration tool
    libsForQt5.qtstyleplugin-kvantum  # Kvantum theme engine for Qt5
    kdePackages.qt6ct  # Qt6 configuration tool
    kdePackages.qtstyleplugin-kvantum  # Kvantum theme engine for Qt6
  ];

  fonts.packages = with pkgs; [
    siji
    noto-fonts
    noto-fonts-color-emoji
    fira-code
  ];

  services.xserver = {
    xkb = {
      layout = "br,us";
      options = "grp:win_space_toggle,terminate:ctrl_alt_bksp";
      variant = ",";
    };
  };

  # Enable touchpad support.
  services.libinput.enable = true;

  location = {
    latitude = -24.0;
    longitude = -54.0;
  };

  # dconf para persistir configurações GTK
  programs.dconf.enable = true;
}
