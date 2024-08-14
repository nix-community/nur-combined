{ config, lib, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # IF TRUE WAYLAND WILL BE USED
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.defaultSession = "gnome";

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    #gedit # text editor
    #epiphany # web browser
    #geary # email reader
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


    glib.dev
    # UTILS
    #gnome.gnome-tweaks

    # IMAGE
    #gnome.gnome-screenshot
    #mipmip_pkg.gnome-screenshot

  ];
}


