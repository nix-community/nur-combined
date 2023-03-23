{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    #NIX/GNOME/HOMEMANAGER
    dconf2nix

    # NEMO-DESKTOP
    cinnamon.nemo

    # GrandPerspective
    baobab

    # SCREENCAST
    peek
    kooha

    # MAIL
    evolution

    # UTILS
    gnome.gnome-tweaks
    gnome.gpaste
    gnome-secrets

    # IMAGE
    #gnome.gnome-screenshot
    mipmip_pkg.gnome-screenshot
    image-roll
    gthumb

    #DEV
    glib.dev
    glade

    #RSS
    newsflash
  ];
}


