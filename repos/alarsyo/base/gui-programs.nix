{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    element-desktop
    feh
    firefox
    ffmpeg
    gimp
    gnome.nautilus
    imagemagick
    mpv
    obs-studio
    pavucontrol
    slack
    spotify
    tdesktop
    teams
    thunderbird
    virt-manager
    zathura

    unstable.discord
  ];

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  programs.steam.enable = true;

  # NOTE: needed for home emacs configuration
  nixpkgs.config.input-fonts.acceptLicense = true;
}
