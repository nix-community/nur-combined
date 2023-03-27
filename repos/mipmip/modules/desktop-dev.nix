{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [

    # GITHUB
    #github-desktop
    gh # GitHub Cli


    alacritty
    xclip
    xorg.xkill

    appimage-run

    vimHugeX
    mipmip_pkg.fred # needed for linny
    mipmip_pkg.mip-rust
    mipmip_pkg.skull


    hugo # needed for linny

    #TRANSLATION TOOLS
    poedit
    intltool
  ];


}
