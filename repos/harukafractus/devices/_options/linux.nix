{ pkgs, lib, config, ... }: {
  imports = [
    ./sessions/cosmic.nix
    ./sessions/gdm.nix
    ./sessions/gnome-minimal.nix
    ./sessions/ibus-engines.nix
    ./workstation/airprint.nix
    ./workstation/audio.nix
    ./workstation/battery.nix
    ./workstation/wifi.nix
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
  };

  services.journald.extraConfig = "SystemMaxUse=50M";

  environment.defaultPackages = lib.mkForce [];

  time.timeZone = lib.mkForce null;

}
