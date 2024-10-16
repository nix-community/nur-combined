{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  # server.

  system.stateVersion = "24.11";

  users.mutableUsers = false;
  services.userborn.enable = true;
  system.etc.overlay.enable = true;
  system.etc.overlay.mutable = false;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
    inherit ((import ../sysctl.nix { inherit lib; }).boot) kernel;
  };

  repack = {
    openssh.enable = true;
    fail2ban.enable = true;
    trojan-server.enable = true;
    dnsproxy = {
      enable = true;
      extraFlags = [ "--ipv6-disabled" ];
    };
  };
  services = {
    metrics.enable = true;

    dnsproxy.settings = lib.mkForce {
      bootstrap = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      listen-addrs = [ "0.0.0.0" ];
      listen-ports = [ 53 ];
      upstream-mode = "parallel";
      upstream = [
        "1.1.1.1"
        "8.8.8.8"
        "https://dns.google/dns-query"
      ];
    };
    hysteria.instances = {
      only = {
        enable = true;
        serve = true;
        openFirewall = 4432;
        credentials = [
          "key:${config.age.secrets."nyaw.key".path}"
          "crt:${config.age.secrets."nyaw.cert".path}"
        ];
        configFile = config.age.secrets.hyst-us.path;
      };
    };
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
