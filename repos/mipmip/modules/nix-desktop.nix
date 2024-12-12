{ config, lib, pkgs, ... }:

{

  # FIX GNOME EPIPHANY
  environment.variables = {
    WEBKIT_FORCE_SANDBOX = "0";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # IF TRUE WAYLAND WILL BE USED
  services.xserver.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "gnome";

  services.flatpak.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "caps:none,terminate:ctrl_alt_bks";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [
    (pkgs.callPackage ../pkgs/drivers/hl4150cdn/default.nix {})
  ];


  # Enable sound.
#sound.enable = true;
#hardware.pulseaudio.enable = true;

  programs = {
    gpaste.enable = true;
  };
}
