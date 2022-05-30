{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dia
    pencil
    gnome.networkmanager-openvpn
    youtube-dl
    tangram
    vscode
    kitty
    git-sync

    nodePackages.livedown

    nodePackages.node2nix

    mipmip_pkg.cryptobox
    cryptsetup

    #NIX/GNOME/HOMEMANAGER
    dconf2nix

    # HARDWARE UTILS
    dmidecode
    pciutils
    xlibs.xvinfo

    newsflash

    # tmux
    urlview

    kooha
    zoom-us
    teams

    #PHOTO ORGANIZER
    shotwell

    #DSTP
    unstable.dstp

    #TRANSLATION TOOLS
    poedit
    intltool

    remmina

    zettlr
    notify
    discord
  ];
}
