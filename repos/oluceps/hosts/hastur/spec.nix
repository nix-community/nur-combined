{
  pkgs,
  config,
  lib,
  ...
}:
{
  system = {
    # This headless machine uses to perform heavy task.
    # Running database and web services.

    stateVersion = "22.11";
    etc.overlay.enable = true;
    etc.overlay.mutable = false;
  }; # Did you read the comment?
  users.mutableUsers = false;
  services = {
    userborn.enable = true;

    smartd.notifications.systembus-notify.enable = true;

    # ktistec.enable = true;
    # radicle.enable = true;
    metrics.enable = true;
    fwupd.enable = true;
    harmonia = {
      enable = true;
      signKeyPaths = [ config.vaultix.secrets.harmonia.path ];
    };
    realm = {
      enable = false;
      settings = {
        log.level = "warn";
        network = {
          no_tcp = false;
          use_udp = true;
        };
        endpoints = [
          {
            listen = "[::]:2222";
            remote = "127.0.0.1:3001";
          }
        ];
      };
    };

    # xserver.videoDrivers = [ "nvidia" ];

    # xserver.enable = true;
    # xserver.displayManager.gdm.enable = true;
    # xserver.desktopManager.gnome.enable = true;

    # nextchat.enable = true;

    snapy.instances = [
      {
        name = "persist";
        source = "/persist";
        keep = "2day";
        timerConfig.onCalendar = "*:0/10";
      }
      {
        name = "var";
        source = "/var";
        keep = "7day";
        timerConfig.onCalendar = "daily";
      }
    ];

    tailscale = {
      enable = false;
      openFirewall = true;
    };

    sing-box.enable = true;

    hysteria.instances = {
      # nodens = {
      #   enable = true;
      #   configFile = config.vaultix.secrets.hyst-us-cli.path;
      # };
      abhoth = {
        enable = true;
        configFile = config.vaultix.secrets.hyst-osa-cli.path;
      };
      yidhra = {
        enable = true;
        configFile = config.vaultix.secrets.hyst-hk-cli.path;
      };
    };
    # shadowsocks.instances = [
    #   {
    #     name = "rha";
    #     configFile = config.vaultix.secrets.ss-az.path;
    #     serve = {
    #       enable = true;
    #       port = 6059;
    #     };
    #   }
    # ];

    gvfs.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      # pulse.enable = true;
      # jack.enable = true;
    };

    minio = {
      enable = true;
      region = "ap-east-1";
      rootCredentialsFile = config.vaultix.secrets.minio.path;
    };

  };
  # system.forbiddenDependenciesRegexes = [ "perl" ];
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';

  zramSwap = {
    enable = false;
    swapDevices = 1;
    memoryPercent = 80;
    algorithm = "zstd";
  };

  # nix.gc = {
  # automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 10d";
  # };
  programs.fish.loginShellInit = ''
    ${pkgs.openssh}/bin/ssh-add ${config.vaultix.secrets.id.path}
  '';
  systemd = {
    enableEmergencyMode = false;
    watchdog = {
      runtimeTime = "20s";
      rebootTime = "30s";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };
  repack = {
    openssh.enable = true;
    fail2ban.enable = true;
    dae.enable = true;
    scrutiny.enable = true;
    # ddns-go.enable = true;
    # atticd.enable = true;
    atuin.enable = true;
    postgresql.enable = true;
    # photoprism.enable = true;
    # mysql.enable = true;
    prometheus.enable = true;
    vaultwarden.enable = true;
    matrix-conduit.enable = true;
    mautrix-telegram.enable = true;
    # coredns.enable = true;
    misskey.enable = true;
    dnsproxy.enable = true;
    srs.enable = true;
    grafana.enable = true;
    meilisearch.enable = true;
    radicle.enable = true;
    # xmrig.enable = true;
    reuse-cert.enable = true;
  };
}
