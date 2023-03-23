{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    openshot-qt
    x264
    ffmpeg
    vlc
  ];
}

