{ pkgs, ... }:
{
  home = {
    username = "deck";
    homeDirectory = "/home/deck";
    packages = with pkgs; [
      r2modman
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          obs-gstreamer
          obs-vkcapture
          obs-vaapi
        ];
      })
    ];
  };
  profiles = {
    chloe.enable = true;
    defaults.enable = true;
    gui.enable = true;
  };
}
