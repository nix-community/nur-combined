{ config, lib, pkgs, unstable, ... }:

{

  services.gnome.gnome-keyring.enable = true;

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    #gedit # text editor
    epiphany # web browser
    geary # email reader
    #gnome-characters
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    yelp # Help view
    #gnome-contacts
    gnome-initial-setup
  ]);

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
    # evolution

    # UTILS
    gnome.gnome-tweaks
    gnome.gpaste
    gnome-secrets

    # IMAGE
    #gnome.gnome-screenshot
    #mipmip_pkg.gnome-screenshot
    #unstable.image-roll
    #gthumb

    #DEV
    glib.dev
    #glade
    cambalache
    #gnome-builder

    #RSS
    #newsflash
  ];
}


