{ pkgs, ... }:
{
  home.packages = with pkgs; [
    grim
    # grimblast
    slurp
    wl-clipboard
    # wl-recorder
    rofi-wayland
    waybar
    gnome.nautilus
    feh
    gnome.file-roller
    evince
    hyprpaper
    wlogout
    gvfs
    udiskie
    libnotify
    networkmanagerapplet
    swayosd
    # swaylock
  ];
  services.blueman-applet.enable = true;
}
