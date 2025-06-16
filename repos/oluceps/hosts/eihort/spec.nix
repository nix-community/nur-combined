{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  vaultix.templates = {
    hyst-osa = {
      content =
        config.vaultix.placeholder.hyst-osa-cli
        + (
          let
            port = toString (lib.conn { }).${config.networking.hostName}.abhoth;
          in
          ''
            socks5:
              listen: 127.0.0.1:1091
            udpForwarding:
            - listen: 127.0.0.1:${port}
              remote: 127.0.0.1:${port}
              timeout: 120s
          ''
        );
      owner = "root";
      group = "users";
      name = "osa.yaml";
      trim = false;
    };
    hyst-hk = {
      content =
        config.vaultix.placeholder.hyst-hk-cli
        + (
          let
            port = toString (lib.conn { }).${config.networking.hostName}.yidhra;
          in
          ''
            socks5:
              listen: 127.0.0.1:1092
            udpForwarding:
            - listen: 127.0.0.1:${port}
              remote: 127.0.0.1:${port}
              timeout: 120s
          ''
        );
      owner = "root";
      group = "users";
      name = "hk.yaml";
      trim = false;
    };
  };
  system = {

    etc.overlay.enable = true;
    etc.overlay.mutable = false;

    stateVersion = "25.05";
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
    plugIn.enable = true;
    openssh.enable = true;
    fail2ban.enable = true;
    # phantomsocks.enable = true;
    dae.enable = true;
    dnsproxy.enable = true;
    scrutiny.enable = true;
    postgresql.enable = true;

    # photoprism.enable = true;
    # mysql.enable = true;

    atuin.enable = true;
    misskey.enable = true;
    meilisearch.enable = true;
    vaultwarden.enable = true;
    tuwunel.enable = true;
    mautrix-telegram.enable = true;
    calibre.enable = true;
    immich.enable = true;
    radicle.enable = true;
    autosign.enable = true;
    aria2.enable = true;
    # linkwarden.enable = true;
    userborn-subid.enable = true;
    ollama.enable = true;

  };

  systemd.services.minio.serviceConfig.Environment = [
    "MINIO_BROWSER_REDIRECT_URL=https://${config.networking.fqdn}/minio"
  ];
  services = {
    rsyncd = {
      enable = true;
      socketActivated = true;
    };
    rqbit = {
      enable = true;
      location = "/three/storage/Downloads";
    };
    bpftune.enable = true;
    # sing-box.enable = true;
    metrics.enable = true;

    online-keeper.instances.sec = {
      sessionFile = config.vaultix.secrets.tg-session.path;
      environmentFile = config.vaultix.secrets.tg-env.path;
    };

    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [
        "/persist"
        "/three"
      ];
    };

    hysteria.instances = {
      abhoth = {
        enable = true;
        configFile = config.vaultix.templates.hyst-osa.path;
      };
      yidhra = {
        enable = true;
        configFile = config.vaultix.templates.hyst-hk.path;
      };
    };

    resolved.enable = lib.mkForce false;
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
        timerConfig.onCalendar = "hourly";
      }
      {
        name = "var";
        source = "/var";
        keep = "3day";
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
