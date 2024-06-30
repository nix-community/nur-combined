{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  # systemd.services.mount-three = {
  #   description = "mount pool 3";
  #   script =
  #     let
  #       diskId = map (n: "/dev/disk/by-id/" + n) [
  #         # "nvme-INTEL_MEMPEK1J016GAH_PHBT82920C53016N"
  #         "wwn-0x5000cca05838bc98"
  #         "wwn-0x5000cca0583a5e34"
  #         "wwn-0x5000cca04608e534"
  #         "wwn-0x5000cca0583880c4"
  #       ];
  #     in
  #     # chain call
  #     toString (
  #       lib.getExe (
  #         pkgs.nuenv.writeScriptBin {
  #           name = "mount";
  #           script =
  #             let
  #               mount = "/run/current-system/sw/bin/mount --onlyonce -o noatime,nodev,nosuid -t bcachefs ${lib.concatStringsSep ":" diskId} /three";
  #             in
  #             ''
  #               do { ${mount} } | complete
  #             '';
  #         }
  #       )
  #     );
  #   wantedBy = [ "multi-user.target" ];
  # };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
  };
  # environment.systemPackages = with pkgs;[ zfs ];
  srv = {
    openssh.enable = true;
    fail2ban.enable = true;
    phantomsocks.enable = true;
    dae.enable = true;
    coredns.enable = true;
    scrutiny.enable = true;
  };

  services = {
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

    resolved.enable = lib.mkForce false;
    tailscale = {
      enable = true;
      openFirewall = true;
    };
    report = {
      enable = true;
      calendars = [ "*-*-* 12:00:00" ];
    };
    mosdns.enable = false;
    minio = {
      enable = true;
      region = "ap-east-1";
      rootCredentialsFile = config.age.secrets.minio.path;
      dataDir = [ "/three/bucket" ];
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

    # compose-up.instances = [
    #   {
    #     name = "misskey";
    #     workingDirectory = "/home/${user}/Src/misskey";
    #   }
    # ];

    hysteria.instances = [
      {
        name = "colour";
        configFile = config.age.secrets.hyst-az-cli.path;
      }
    ];

    shadowsocks.instances = [
      {
        name = "rha";
        configFile = config.age.secrets.ss-az.path;
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

  systemd.tmpfiles.rules = [ ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
