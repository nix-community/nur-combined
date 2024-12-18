{ config, lib, pkgs, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
#    openshot-qt
    x264
    ffmpeg
    vlc
    vhs

    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        advanced-scene-switcher
        input-overlay
        obs-backgroundremoval
        obs-composite-blur
        #obs-pipewire-audio-capture
      ];
    })
  ];
}

