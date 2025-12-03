{ config, lib, ... }:
let
  fsOpts = import ./fs-opts.nix;
  ifSshAuthorized = lib.mkIf (((config.sane.hosts.by-name."${config.networking.hostName or ""}" or {}).ssh or {}).authorized or false);

  remoteHome = name: { host ? name }: let
    mountpoint = "/mnt/${name}/home";
    device = "sshfs#colin@${host}:/home/colin";
    fsType = "fuse3";
    options = fsOpts.sshColin ++ fsOpts.lazyMount;
  in {
    sane.programs.sshfs-fuse.enableFor.system = true;
    system.fsPackages = [
      config.sane.programs.sshfs-fuse.package
    ];
    fileSystems."${mountpoint}" = {
      inherit device fsType options;
      noCheck = true;
    };
    # tell systemd about the mount so that i can sandbox it
    systemd.mounts = [{
      where = mountpoint;
      what = device;
      type = fsType;
      options = lib.concatStringsSep "," options;
      wantedBy = [ "default.target" ];
      after = [
        "emergency.service"
        "network-online.target"
      ];
      requires = [ "network-online.target" ];

      unitConfig.Conflicts = [
        # emergency.service drops the user into a root shell;
        # only accessible via physical TTY, but unmount sensitive data before that as a precaution.
        "emergency.service"
      ];

      # mountConfig.LazyUnmount = true;  #< else it _ocassionally_ fails "target is busy"

      mountConfig.ExecSearchPath = [ "/run/current-system/sw/bin" ];
      mountConfig.User = "colin";
      mountConfig.AmbientCapabilities = "CAP_SETPCAP CAP_SYS_ADMIN";
      # hardening (systemd-analyze security mnt-desko-home.mount):
      # TODO: i can't use ProtectSystem=full here, because i can't create a new mount space; but...
      # with drop_privileges, i *could* sandbox the actual `sshfs` program using e.g. bwrap
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
      mountConfig.IPAddressAllow = "10.0.0.0/8";
      mountConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
      mountConfig.DeviceAllow = "/dev/fuse";
      # mount.mountConfig.RestrictNamespaces = true;  #< my sshfs sandboxing uses bwrap
    }];
  };
in
lib.mkMerge [
  (ifSshAuthorized (remoteHome "crappy" {}))
  (ifSshAuthorized (remoteHome "desko" { host = "desko-hn"; }))
  (ifSshAuthorized (remoteHome "flowy" {}))
  # (ifSshAuthorized (remoteHome "lappy" {}))
  (ifSshAuthorized (remoteHome "moby" { host = "moby-hn"; }))
  (ifSshAuthorized (remoteHome "servo" {}))
]
