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
    pkgs.texlive.combined.scheme-full
  ];
  nix.settings.trusted-users = [ "riro" ];

  services.hardware.openrgb.enable = true;
  # systemd.services.systemd-networkd.serviceConfig.Environment = [ "SYSTEMD_LOG_LEVEL=debug" ];
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

    blueman.enable = true;
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
    # harmonia = {
    #   enable = true;
    #   settings.bind = "[::]:5000";
    #   signKeyPaths = [ config.vaultix.secrets.harmonia.path ];
    # };

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

    # tailscale = {
    #   enable = true;
    #   openFirewall = true;
    #   disableTaildrop = true;
    # };

    sing-box.enable = true;

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

    # sleep.settings.Sleep.AllowHibernation = "no";
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
    # alloy.enable = true;
    # zeek.enable = true;
    earlyoom.enable = true;
    incus = {
      enable = true;
      bridgeAddr = "fdcc:1::1/64";
    };
  };
}
