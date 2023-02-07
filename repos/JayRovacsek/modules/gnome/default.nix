{ config, pkgs, lib, ... }:
let
  tailscaleExtensions = if config.services.tailscale.enable then
    with pkgs.gnomeExtensions; [ tailscale-status ]
  else
    [ ];

  gnomePackages = with pkgs.gnome; [
    gnome-tweaks
    nautilus
    dconf-editor
    gnome-screenshot
  ];
  gnomeExtensions = with pkgs.gnomeExtensions;
    [
      caffeine
      screenshot-tool
      sensory-perception
      pop-shell
      blur-my-shell
      notification-banner-reloaded
    ] ++ tailscaleExtensions;
in {
  imports = [ ../redshift ];

  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.enable = true;

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = false;
  };

  services.gvfs.enable = true;

  environment.systemPackages = with pkgs;
    [ gjs ] ++ gnomePackages ++ gnomeExtensions;

  # If using gnome desktop manager, exclude these from installation
  environment.gnome.excludePackages = with pkgs; [
    gnome.cheese
    gnome-photos
    gnome.gnome-music
    gnome.gedit
    epiphany
    evince
    gnome.gnome-characters
    gnome.totem
    gnome.tali
    gnome.iagno
    gnome.hitori
    gnome.atomix
    gnome.gnome-weather
    gnome.gnome-contacts
    gnome.gnome-maps
    gnome.geary
    gnome-tour
    gnome-connections
  ];
}
