{ pkgs, ... }:

{
  # Graphical environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.gnome.excludePackages = with pkgs.gnome; [
    epiphany
    geary
    gnome-calculator
    gnome-maps
    gnome-music
    gnome-weather
  ];
  # Workaround for NixOS/nixpkgs#92265
  services.xserver.desktopManager.gnome.sessionPath = [ pkgs.gnomeExtensions.pop-shell ];

  # Audio
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  systemd.services.rtkit-daemon.serviceConfig.LogLevelMax = "notice";
  services.pipewire = {
    enable = true;
    alsa = { enable = true; support32Bit = true; };
    pulse.enable = true;
  };
}
