{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    chatterino2
    discord
    element-desktop
    firefox
    imv
    paperwork
    slack
    spotify
    zoom-us
  ];


  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-wlrobs ];
  };

  programs.zathura.enable = true;
}
