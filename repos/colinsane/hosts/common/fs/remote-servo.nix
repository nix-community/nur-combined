{ config, lib, utils, ... }:
let
  fsOpts = import ./fs-opts.nix;
  commonOptions = fsOpts.ftp ++ fsOpts.noauto;
  mountpoint = "/mnt/.servo_ftp";
  systemdName = utils.escapeSystemdPath mountpoint;
  device = "curlftpfs#ftp://servo-hn:/";
  fsType = "fuse3";
  options = commonOptions ++ [
    # systemd (or maybe fuse?) swallows stderr of mount units with no obvious fix.
    # instead, use this flag to log the mount output to disk
    "stderr_path=/var/log/curlftpfs/servo-hn.stderr"
  ];

  remoteServo = subdir: let
    systemdBindName = utils.escapeSystemdPath "/mnt/servo/${subdir}";
  in {
    # sane.fs."/mnt/servo/${subdir}".mount.bind = "/mnt/.servo_ftp/${subdir}";
    systemd.mounts = [{
      where = "/mnt/servo/${subdir}";
      what = "/mnt/.servo_ftp/${subdir}";
      options = "bind,nofail";
      type = "auto";

      after = [ "${systemdName}.mount" ];
      upheldBy = [ "${systemdName}.mount" ];  #< start this mount whenever the underlying becomes available
      bindsTo = [ "${systemdName}.mount" ];  #< stop this mount whenever the underlying disappears
    }];
  };
in
lib.mkMerge [
  {
    sane.programs.curlftpfs.enableFor.system = true;
    system.fsPackages = [
      config.sane.programs.curlftpfs.package
    ];

    sane.fs."/var/log/curlftpfs".dir.acl.mode = "0777";

    fileSystems."/mnt/.servo_ftp" = {
      inherit device fsType options;
      noCheck = true;
    };
    systemd.mounts = [{
      where = mountpoint;
      what = device;
      type = fsType;
      options = lib.concatStringsSep "," options;
      wantedBy = [ "default.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];

      #VVV patch so that when the mount fails, we start a timer to remount it.
      #    and for a disconnection after a good mount (onSuccess), restart the timer to be more aggressive
      unitConfig.OnFailure = [ "${systemdName}.timer" ];
      unitConfig.OnSuccess = [ "${systemdName}-restart-timer.target" ];

      mountConfig.TimeoutSec = "10s";
      mountConfig.ExecSearchPath = [ "/run/current-system/sw/bin" ];
      mountConfig.User = "colin";
      mountConfig.AmbientCapabilities = "CAP_SETPCAP CAP_SYS_ADMIN";
      # hardening (systemd-analyze security mnt-servo-playground.mount)
      mountConfig.CapabilityBoundingSet = "CAP_SETPCAP CAP_SYS_ADMIN";
      mountConfig.LockPersonality = true;
      mountConfig.MemoryDenyWriteExecute = true;
      mountConfig.NoNewPrivileges = true;
      mountConfig.ProtectClock = true;
      mountConfig.ProtectHostname = true;
      mountConfig.RemoveIPC = true;
      mountConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
      #VVV this includes anything it reads from, e.g. /bin/sh; /nix/store/...
      # see `systemd-analyze filesystems` for a full list
      mountConfig.RestrictFileSystems = "@common-block @basic-api fuse";
      mountConfig.RestrictRealtime = true;
      mountConfig.RestrictSUIDSGID = true;
      mountConfig.SystemCallArchitectures = "native";
      mountConfig.SystemCallFilter = [
        "@system-service"
        "@mount"
        "~@chown"
        "~@cpu-emulation"
        "~@keyring"
        # could remove almost all io calls, however one has to keep `open`, and `write`, to communicate with the fuse device.
        # so that's pretty useless as a way to prevent write access
      ];
      mountConfig.IPAddressDeny = "any";
      mountConfig.IPAddressAllow = "10.0.10.5";
      mountConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
      mountConfig.DeviceAllow = "/dev/fuse";
      # mountConfig.RestrictNamespaces = true;
    }];

    systemd.targets."${systemdName}-restart-timer" = {
      # hack unit which, when started, stops the timer (if running), and then starts it again.
      after = [ "${systemdName}.timer" ];
      conflicts = [ "${systemdName}.timer" ];
      upholds = [ "${systemdName}.timer" ];
      unitConfig.StopWhenUnneeded = true;
    };
    systemd.timers."${systemdName}" = {
      timerConfig.Unit = "${systemdName}.mount";
      timerConfig.AccuracySec = "2s";
      timerConfig.OnActiveSec = [
        # try to remount at these timestamps, backing off gradually
        # there seems to be an implicit mount attempt at t=0.
        "10s"
        "30s"
        "60s"
        "120s"
      ];
      # cap the backoff to a fixed interval.
      timerConfig.OnUnitActiveSec = [ "120s" ];
    };
  }

  # this granularity of servo media mounts is necessary to support sandboxing. consider:
  #   1. servo offline
  #   2. launch a long-running app
  #   3. servo comes online
  # in order for the servo mount to be propagated into the app's namespace, we need to bind
  # the root mountpoint into the app namespace. if we wish to only grant the app selective access
  # to servo, we must create *multiple* mountpoints: /mnt/servo/FOO directories which always exist,
  # and are individually bound to /mnt/.servo_ftp/FOO as the latter becomes available.
  (remoteServo "media/archive")
  (remoteServo "media/Books")
  (remoteServo "media/collections")
  # (remoteServo "media/datasets")
  (remoteServo "media/games")
  (remoteServo "media/Music")
  (remoteServo "media/Pictures/macros")
  (remoteServo "media/torrents")
  (remoteServo "media/Videos")
  (remoteServo "playground")
]
