{ pkgs, config, lib, inputs, ... }:
{
  # server inside the cage.

  system.stateVersion = "23.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
    inherit ((import ../../boot.nix { inherit lib; }).boot) kernel;
  };

  services = lib.mkMerge [
    {

      inherit ((import ../../services.nix
        ((import ../lib.nix { inherit inputs; }).base
          // { inherit pkgs config; })).services)
        dae
        openssh
        mosdns
        fail2ban
        ;
    }
    {
      dae.enable = true;
      sing-box.enable = true;
    }
  ];

  networking.firewall = {
    allowedUDPPorts = [ 6059 ];
    allowedTCPPorts = [ 6059 ];
  };


  programs = {
    git.enable = true;
    fish.enable = true;
  };
  zramSwap = {
    enable = true;
    swapDevices = 1;
    memoryPercent = 80;
    algorithm = "zstd";
  };

  systemd = {
    enableEmergencyMode = false;
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 10s.
      # If the hardware watchdog does not get a signal for 20s,
      # it will forcefully reboot the system.
      runtimeTime = "20s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };

  };

  systemd.tmpfiles.rules = [
  ];
}
