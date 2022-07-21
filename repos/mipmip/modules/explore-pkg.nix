{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome.networkmanager-openvpn
    youtube-dl
    kitty
    git-sync

    #nodePackages.livedown
    #nodePackages.node2nix

    mipmip_pkg.cryptobox
    cryptsetup

    #NIX/GNOME/HOMEMANAGER
    dconf2nix

    newsflash

    kooha

    #DSTP
    dstp

    #TRANSLATION TOOLS
    poedit
    intltool

    notify
    slop
  ];
}
