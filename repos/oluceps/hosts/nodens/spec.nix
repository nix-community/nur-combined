{
  pkgs,
  config,
  lib,
  ...
}:
{
  # server.

  system.stateVersion = "22.11";

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
    rustypaste.enable = true;
    matrix-sliding-sync.enable = true;
    trojan-server.enable = true;
    dnsproxy = {
      enable = true;
    };
    reuse-cert.enable = true;
  };
  services = {
    # override repack
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
            listen = "[::]:8776";
            remote = "10.0.1.2:8776";
          }
        ];
      };
    };
    metrics.enable = true;
    do-agent.enable = true;
    # copilot-gpt4.enable = true;
    factorio-manager = {
      enable = true;
      factorioPackage = pkgs.factorio-headless-experimental;
      botConfigPath = config.age.secrets.factorio-manager-bot.path;
      initialGameStartArgs = [
        "--server-settings=${config.age.secrets.factorio-server.path}"
        "--server-adminlist=${config.age.secrets.factorio-admin.path}"
      ];
    };

    coturn = {
      enable = true;
      # static-auth-secret-file = config.age.secrets.wg.path;
      no-auth = true;
      realm = config.networking.fqdn;
    };

    ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":2586";
        behind-proxy = true;
        auth-default-access = "deny-all";
        base-url = "http://ntfy.nyaw.xyz";
      };
    };

    # online-keeper.instances = [
    #   {
    #     name = "sec";
    #     sessionFile = config.age.secrets.tg-session.path;
    #     environmentFile = config.age.secrets.tg-env.path;
    #   }
    # ];

    juicity.instances = {
      only = {
        enable = true;
        credentials = [
          "key:${config.age.secrets."nyaw.key".path}"
          "cert:${config.age.secrets."nyaw.cert".path}"
        ];
        serve = true;
        openFirewall = 23180;
        configFile = config.age.secrets.juic-san.path;
      };
    };

    hysteria.instances = {
      only = {
        enable = true;
        serve = true;
        openFirewall = 4432;
        credentials = [
          "key:${config.age.secrets."nyaw.key".path}"
          "cert:${config.age.secrets."nyaw.cert".path}"
        ];
        configFile = config.age.secrets.hyst-us.path;
      };
    };
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
