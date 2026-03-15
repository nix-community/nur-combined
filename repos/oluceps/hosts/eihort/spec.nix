{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  security.auditd.enable = true;
  system = {

    etc.overlay.enable = true;
    etc.overlay.mutable = true;

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
  };
  repack = {
    plugIn.enable = true;
    openssh.enable = true;
    fail2ban.enable = true;
    # phantomsocks.enable = true;
    dae.enable = true;
    # dnsproxy.enable = true;
    scrutiny.enable = true;
    postgresql.enable = true;

    atuin.enable = true;
    misskey.enable = true;
    meilisearch.enable = true;
    vaultwarden.enable = true;
    # tuwunel.enable = true;
    mautrix-telegram.enable = true;
    synapse.enable = true;
    calibre.enable = true;
    immich.enable = true;
    radicle.enable = true;
    aria2.enable = true;
    userborn-subid.enable = true;
    # ollama.enable = true;
    seaweedfs.enable = true;

    prometheus.enable = true;
    grafana.enable = true;
    # incus = {
    #   enable = true;
    #   bridgeAddr = "fdcc:3::1/64";
    # };
    # telegram-search.enable = true;
    loki.enable = true;
    alloy.enable = true;
    zeek.enable = true;
    jellyfin.enable = true;
    samba.enable = true;
    ncps.enable = true;
  };

  # systemd.services.minio.serviceConfig.Environment = [
  #   "MINIO_BROWSER_REDIRECT_URL=https://${config.networking.fqdn}/minio"
  # ];
  services = {
    rsyncd = {
      enable = true;
      socketActivated = true;
    };
    cloudflared = {
      enable = true;
      environmentFile = config.vaultix.secrets.cfd.path;
    };
    nuanmonito = {
      enable = true;
      package = inputs.nuanmonito.packages.${pkgs.stdenv.hostPlatform.system}.nuanmonito;
      environmentFile = config.vaultix.secrets.nuan.path;
    };
    memos = {
      enable = true;
      instanceUrl = "https://memos.nyaw.xyz";
      mode = "dev";
      port = 5230;
      environmentFile = config.vaultix.secrets.memos.path;
    };
    target = {
      enable = true;
      # ugly
      config = builtins.fromJSON (builtins.readFile ./target_cfg.json);
    };
    # openiscsi = {
    #   enable = true;
    #   discoverPortal = "ip:3260";
    #   name = "iqn.2005-10.org.nixos.ctl:ntfs-games";
    # };
    rqbit = {
      enable = true;
      location = "/three/storage/Downloads";
    };
    # bpftune.enable = true;
    sing-box.enable = true;
    metrics.enable = true;
    online-exporter.instances.zro = {
      # sessionFile = config.vaultix.secrets.tgexp.path;
      environment = [
        "TG_API_HASH=d524b414d21f4d37f08684c1df41ac9c"
        "TG_API_ID=611335"
        "MONITOR_USER_IDS=454999736,6280888824,594807459"
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
            listen = "[::]:1905";
            remote = "10.255.0.1:1095";
          }
        ];
      };
    };
    pocket-id = {
      enable = true;
      settings = {
        APP_URL = "https://oidc.nyaw.xyz";
        TRUST_PROXY = true;
        OTEL_METRICS_EXPORTER = "prometheus";
      };
      environmentFile = config.vaultix.secrets.pocketid.path;
    };

    # online-keeper.instances.sec = {
    #   sessionFile = config.vaultix.secrets.tg-session.path;
    #   environmentFile = config.vaultix.secrets.tg-env.path;
    # };

    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [
        "/persist"
        "/three"
      ];
    };

    # minio = {
    #   enable = true;
    #   region = "ap-east-1";
    #   rootCredentialsFile = config.vaultix.secrets.minio.path;
    #   dataDir = [ "/three/bucket" ];
    # };

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
    git = {
      enable = true;
      package = pkgs.gitMinimal;
    };
    fish.enable = true;
  };

  systemd = {
    enableEmergencyMode = true;
    # systemd will send a signal to the hardware watchdog at half
    # the interval defined here, so every 10s.
    # If the hardware watchdog does not get a signal for 20s,
    # it will forcefully reboot the system.
    settings.Manager = {
      RebootWatchdogSec = "3min";
      RuntimeWatchdogSec = "60s";
    };
  };

  systemd.tmpfiles.rules = [ ]; # Did you read the comment?
}
