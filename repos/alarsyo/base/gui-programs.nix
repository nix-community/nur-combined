{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    element-desktop
    feh
    firefox
    gimp
    gnome.nautilus
    imagemagick
    mpv
    pavucontrol
    slack
    spotify
    tdesktop
    teams
    thunderbird
    zathura

    unstable.discord
  ];

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  programs.steam.enable = true;

  # NOTE: needed for home emacs configuration
  nixpkgs.config.input-fonts.acceptLicense = true;
}
