{ config, ... }:
let
  zfsBootSupported =
    builtins.any (x: x == "zfs") config.boot.supportedFilesystems;

  zfsServiceSupported = config.services.zfs.autoScrub.enable
    || config.services.zfs.autoSnapshot.enable;

  enableNvidia =
    builtins.any (x: x == "nvidia") config.services.xserver.videoDrivers;

  systemdUnitConfigs = {
    systemd.services.docker.after =
      if zfsBootSupported || zfsServiceSupported then
        [ "zfs-mount.service" ]
      else
        [ ];

    systemd.services.docker.unitConfig.RequiresMountsFor = "/var/lib/docker";
  };

  cfg = {
    virtualisation = {
      oci-containers.backend = "docker";
      docker = {
        inherit enableNvidia;
        enable = true;
        rootless.enable = true;
        autoPrune.enable = true;
      };
    };
  } // systemdUnitConfigs;

in cfg
