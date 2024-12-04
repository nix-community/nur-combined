{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  system = {

    etc.overlay.enable = true;
    etc.overlay.mutable = false;

    stateVersion = "24.05";
  };
  services.userborn.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = [ pkgs.gdu ];
  users.mutableUsers = false;
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
  };
  # environment.systemPackages = with pkgs;[ zfs ];
  repack = {
    openssh.enable = true;
    fail2ban.enable = true;
    phantomsocks.enable = true;
    dae.enable = true;
    dnsproxy.enable = true;
    scrutiny.enable = true;
    postgresql.enable = true;
    photoprism.enable = true;
    mysql.enable = true;
  };

  services = {
    rsyncd = {
      enable = true;
      socketActivated = true;
    };
    bpftune.enable = true;
    sing-box.enable = true;
    metrics.enable = true;
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [
        "/persist"
        "/three"
      ];
    };

    hysteria.instances = {
      nodens = {
        enable = true;
        configFile = config.vaultix.secrets.hyst-us-cli.path;
      };
      yidhra = {
        enable = true;
        configFile = config.vaultix.secrets.hyst-hk-cli.path;
      };
    };

    resolved.enable = lib.mkForce false;
    tailscale = {
      enable = true;
      openFirewall = true;
    };
    mosdns.enable = false;
    minio = {
      enable = true;
      region = "ap-east-1";
      rootCredentialsFile = config.vaultix.secrets.minio.path;
      dataDir = [ "/three/bucket" ];
    };

    snapy.instances = [
      {
        name = "persist";
        source = "/persist";
        keep = "2day";
        timerConfig.onCalendar = "12h";
      }
      {
        name = "var";
        source = "/var";
        keep = "7day";
        timerConfig.onCalendar = "daily";
      }
    ];

    shadowsocks.instances = [
      {
        name = "rha";
        configFile = config.vaultix.secrets.ss-az.path;
        serve = {
          enable = true;
          port = 6059;
        };
      }
    ];
  };

  programs = {
    git.enable = true;
    fish.enable = true;
  };

  systemd = {
    enableEmergencyMode = true;
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

  systemd.tmpfiles.rules = [ ]; # Did you read the comment?
}
