{ pkgs, ... }:

{
  # Graphical environment
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-calculator
    gnome-maps
    gnome-music
    gnome-weather
  ];

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  systemd.services.rtkit-daemon.serviceConfig.LogLevelMax = "notice";
  services.pipewire = {
    alsa = { enable = true; support32Bit = true; };
    pulse.enable = true;
  };
}
