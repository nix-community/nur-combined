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

      # Gnome3 tools
      gnome3.gnome-shell-extensions
      gnome3.gnome-tweak-tool
    ]
  );

  # X-Server and Gnome3 desktop configuration
  services.xserver.enable = mkDefault true;
  services.xserver.layout = mkDefault "de";

  services.xserver.displayManager.gdm.enable = mkDefault true;
  # Disable wayland if the nvidia driver is used
  services.xserver.displayManager.gdm.wayland = mkDefault (!(any (v: v == "nvidia") config.services.xserver.videoDrivers));
  services.xserver.desktopManager.gnome3.enable = mkDefault true;

  # Gnome3 adjustments
  environment.gnome3.excludePackages = with pkgs; [
    epiphany
    gnome3.gnome-software
    gnome3.totem
  ];

  programs.geary.enable = false;

  services.gnome3.evolution-data-server.enable = mkForce false;
  services.gnome3.gnome-online-accounts.enable = false;
  services.gnome3.gnome-online-miners.enable = mkForce false;
  services.gnome3.gnome-remote-desktop.enable = false;
  services.gnome3.gnome-user-share.enable = false;
  services.gnome3.rygel.enable = false;
  services.gnome3.tracker.enable = false;
  services.gnome3.tracker-miners.enable = false;

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
