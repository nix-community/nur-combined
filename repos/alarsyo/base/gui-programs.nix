{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    element-desktop
    feh
    gimp
    gnome.nautilus
    imagemagick
    mpv
    pavucontrol
    thunderbird
    zathura

    unstable.discord
    unstable.firefox
    unstable.slack
    unstable.spotify
    unstable.tdesktop
    unstable.teams
  ];

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  programs.steam.enable = true;

  # NOTE: needed for home emacs configuration
  nixpkgs.config.input-fonts.acceptLicense = true;
}
