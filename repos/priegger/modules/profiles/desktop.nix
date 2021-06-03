{ config, lib, pkgs, ... }:
with lib;
let
  common = import ./common.nix { inherit config pkgs lib; };
in
recursiveUpdate common {
  environment.systemPackages = common.environment.systemPackages ++ (
    with pkgs; [
      # dev tools
      gitAndTools.gitFull

      # misc tools
      gnupg

      # Gnome tools
      gnome.gnome-shell-extensions
      gnome.gnome-tweak-tool
    ]
  );

  # X-Server and Gnome desktop configuration
  services.xserver.enable = mkDefault true;
  services.xserver.layout = mkDefault "de";

  services.xserver.displayManager.gdm.enable = mkDefault true;
  # Disable wayland if the nvidia driver is used
  services.xserver.displayManager.gdm.wayland = mkDefault (!(any (v: v == "nvidia") config.services.xserver.videoDrivers));
  services.xserver.desktopManager.gnome.enable = mkDefault true;

  # Gnome adjustments
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome.cheese
    gnome.gnome-software
    gnome.totem
  ];

  programs.geary.enable = false;

  services.gnome.evolution-data-server.enable = mkForce false;
  services.gnome.gnome-online-accounts.enable = false;
  services.gnome.gnome-online-miners.enable = mkForce false;
  services.gnome.gnome-remote-desktop.enable = false;
  services.gnome.gnome-user-share.enable = false;
  services.gnome.rygel.enable = false;
  services.gnome.tracker.enable = false;
  services.gnome.tracker-miners.enable = false;

  xdg.portal.enable = mkForce false;

  # Typically needed for wifi drivers and the like
  hardware.enableRedistributableFirmware = mkDefault true;

  # Networking
  networking.networkmanager.enable = mkDefault true;

  # Sound
  sound.enable = mkDefault true;
  hardware.pulseaudio.enable = mkDefault true;

  # 32bit graphics and sound support for steam
  hardware.opengl.driSupport32Bit = mkDefault true;
  hardware.pulseaudio.support32Bit = mkDefault true;
}
