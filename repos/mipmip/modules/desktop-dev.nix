{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [

    alacritty
    xclip
    xorg.xkill

    appimage-run

    vimHugeX
    mipmip_pkg.mip-rust



    hugo # needed for linny

    #TRANSLATION TOOLS
    poedit
    intltool
  ];


}
