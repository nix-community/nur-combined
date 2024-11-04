{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  # server inside the cage.

  system.stateVersion = "24.05";

  users.mutableUsers = false;
  services.userborn.enable = true;
  system.etc.overlay.enable = true;
  system.etc.overlay.mutable = false;
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
    inherit ((import ../sysctl.nix { inherit lib; }).boot) kernel;
  };
  repack = {
    openssh.enable = true;
    fail2ban.enable = true;
    dae.enable = false;
    srs.enable = true;
    dnsproxy = {
      enable = true;
      extraFlags = [ "--ipv6-disabled" ];
    };
  };

  services = {
    sing-box.enable = true;
    metrics.enable = true;

    realm = {
      enable = true;
      settings = {
        log.level = "warn";
        network = {
          no_tcp = false;
          use_udp = true;
        };
        endpoints = [
          {
            listen = "[::]:8448";
            remote = "10.0.2.2:43000";
          }
          {
            listen = "[::]:34197";
            remote = "10.0.1.1:34197";
          }
        ];
      };
    };
  };
  services.hysteria.instances = {
    nodens = {
      enable = true;
      configFile = config.vaultix.secrets.hyst-us-cli.path;
    };
    abhoth = {
      enable = true;
      configFile = config.vaultix.secrets.hyst-la-cli.path;
    };
    yidhra = {
      enable = true;
      configFile = config.vaultix.secrets.hyst-hk-cli.path;
    };
  };

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

  systemd.tmpfiles.rules = [ ];
}
