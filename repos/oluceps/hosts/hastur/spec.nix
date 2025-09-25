{
  pkgs,
  config,
  lib,
  user,
  ...
}:
{
  environment.systemPackages = [
    pkgs.nvtopPackages.intel
  ];
  # systemd.services.systemd-networkd.serviceConfig.Environment = [ "SYSTEMD_LOG_LEVEL=debug" ];
  vaultix.templates = {
    hyst-tyo = {
      content =
        config.vaultix.placeholder.hyst-tyo-cli
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
      name = "tyo.yaml";
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
    # This headless machine uses to perform heavy task.
    # Running database and web services.

    stateVersion = "24.11";
    etc.overlay = {
      enable = true;
      mutable = false;
    };
  }; # Did you read the comment?
  users.mutableUsers = false;
  services = {
    userborn.enable = true;

    syncthing = {
      enable = true;
      openDefaultPorts = true;
      inherit user;
      guiAddress = "[::]:8384";
    };
    smartd.notifications.systembus-notify.enable = true;
    # wg-refresh = {
    #   enable = true;
    #   calendar = "hourly";
    # };

    # ktistec.enable = true;
    # radicle.enable = true;
    metrics.enable = true;
    # fwupd.enable = true;
    harmonia = {
      enable = true;
      settings.bind = "[::]:5000";
      signKeyPaths = [ config.vaultix.secrets.harmonia.path ];
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
            listen = "[fdcc::1]:1701";
            remote = "10.255.0.1:8080";
          }
        ];
      };
    };

    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [
        "/persist"
      ];
    };
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
        configFile = config.vaultix.templates.hyst-tyo.path;
      };
      yidhra = {
        enable = true;
        configFile = config.vaultix.templates.hyst-hk.path;
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

  };
  # system.forbiddenDependenciesRegexes = [ "perl" ];
  # environment.etc."resolv.conf".text = ''
  #   nameserver 127.0.0.1
  #   search nyaw.xyz
  # '';

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
  systemd = {

    # user.services.add-ssh-keys = {
    #   script = ''
    #     ${pkgs.openssh}/bin/ssh-add <>
    #   '';
    #   wantedBy = [ "default.target" ];
    #   after = [ "gcr-ssh-agent.service" ];
    # };
    enableEmergencyMode = false;
    settings.Manager = {
      RebootWatchdogSec = "20s";
      RuntimeWatchdogSec = "30s";
    };

    sleep.extraConfig = ''
      # AllowSuspend=no
      AllowHibernation=no
    '';
  };
  repack = {
    plugIn.enable = true;
    openssh.enable = true;
    fail2ban.enable = true;
    dae.enable = true;
    scrutiny.enable = true;
    # ddns-go.enable = true;
    # atticd.enable = true;
    # photoprism.enable = true;
    # mysql.enable = true;
    # coredns.enable = true;
    dnsproxy = {
      enable = false;
      extraFlags = [
        "--edns-addr=211.139.163.1"
      ];
      # lazy = true;
    };
    # srs.enable = true;
    # xmrig.enable = true;
    garage.enable = true;

    userborn-subid.enable = true;
    # postgresql.enable = true;
    # misskey.enable = true;
    # vaultwarden.enable = true;
    # conduwuit.enable = true;
    # mautrix-telegram.enable = true;
    # calibre.enable = true;
    ipex.enable = true;
    routed-subnet.enable = true;
    loki.enable = true;
    alloy.enable = true;
    zeek.enable = true;
  };
}
