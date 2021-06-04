{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alacritty
    feh
    gnome.nautilus
    mpv
    pavucontrol
    thunderbird
    zathura

    unstable.discord
    unstable.firefox
    unstable.element-desktop
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
