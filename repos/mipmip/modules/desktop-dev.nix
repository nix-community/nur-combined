{ config, lib, unstable, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [

    # terminals
    dialog
    gnome.zenity
    foot

    xclip
    xorg.xkill

    appimage-run

    vimHugeX
    mipmip_pkg.mip-rust

    actionlint

    unstable.hugo # needed for linny

    #TRANSLATION TOOLS
    poedit
    intltool


    super-productivity
  ];


}
