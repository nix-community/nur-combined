{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    chatterino2
    discord
    element-desktop
    imv
    paperwork
    slack
    spotify
    zoom-us
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
  };

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-wlrobs ];
  };

  programs.zathura.enable = true;
}
