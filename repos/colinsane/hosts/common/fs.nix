# docs
# - x-systemd options: <https://www.freedesktop.org/software/systemd/man/systemd.mount.html>
# - fuse options: `man mount.fuse`

{ config, lib, utils, ... }:

let
  fsOpts = rec {
    common = [
      "_netdev"
      "noatime"
      # user: allow any user with access to the device to mount the fs.
      #       note that this requires a suid `mount` binary; see: <https://zameermanji.com/blog/2022/8/5/using-fuse-without-root-on-linux/>
      "user"
      "x-systemd.requires=network-online.target"
      "x-systemd.after=network-online.target"
      "x-systemd.mount-timeout=10s"  # how long to wait for mount **and** how long to wait for unmount
    ];
    # x-systemd.automount: mount the fs automatically *on first access*.
    # creates a `path-to-mount.automount` systemd unit.
    automount = [ "x-systemd.automount" ];
    # noauto: don't mount as part of remote-fs.target.
    # N.B.: `remote-fs.target` is a dependency of multi-user.target, itself of graphical.target.
    # hence, omitting `noauto` can slow down boots.
    noauto = [ "noauto" ];
    # lazyMount: defer mounting until first access from userspace.
    # see: `man systemd.automount`, `man automount`, `man autofs`
    lazyMount = noauto ++ automount;

    fuse = [
      "allow_other"  # allow users other than the one who mounts it to access it. needed, if systemd is the one mounting this fs (as root)
      # allow_root: allow root to access files on this fs (if mounted by non-root, else it can always access them).
      #             N.B.: if both allow_root and allow_other are specified, then only allow_root takes effect.
      # "allow_root"
      # default_permissions: enforce local permissions check. CRUCIAL if using `allow_other`.
      # w/o this, permissions mode of sshfs is like:
      # - sshfs runs all remote commands as the remote user.
      # - if a local user has local permissions to the sshfs mount, then their file ops are sent blindly across the tunnel.
      # - `allow_other` allows *any* local user to access the mount, and hence any local user can now freely become the remote mapped user.
      # with default_permissions, sshfs doesn't tunnel file ops from users until checking that said user could perform said op on an equivalent local fs.
      "default_permissions"
    ];
    fuseColin = fuse ++ [
      "uid=1000"
      "gid=100"
    ];

    ssh = common ++ fuseColin ++ [
      "identityfile=/home/colin/.ssh/id_ed25519"
      # i *think* idmap=user means that `colin` on `localhost` and `colin` on the remote are actually treated as the same user, even if their uid/gid differs?
      # i.e., local colin's id is translated to/from remote colin's id on every operation?
      "idmap=user"
    ];
    sshColin = ssh ++ fuseColin ++ [
      # follow_symlinks: remote files which are symlinks are presented to the local system as ordinary files (as the target of the symlink).
      #                  if the symlink target does not exist, the presentation is unspecified.
      #                  symlinks which point outside the mount ARE followed. so this is more capable than `transform_symlinks`
      "follow_symlinks"
      # symlinks on the remote fs which are absolute paths are presented to the local system as relative symlinks pointing to the expected data on the remote fs.
      # only symlinks which would point inside the mountpoint are translated.
      "transform_symlinks"
    ];
    # sshRoot = ssh ++ [
    #   # we don't transform_symlinks because that breaks the validity of remote /nix stores
    #   "sftp_server=/run/wrappers/bin/sudo\\040/run/current-system/sw/libexec/sftp-server"
    # ];

    # manually perform a ftp mount via e.g.
    #   curlftpfs -o ftpfs_debug=2,user=anonymous:anonymous,connect_timeout=10 -f -s ftp://servo-hn /mnt/my-ftp
    ftp = common ++ fuseColin ++ [
      # "ftpfs_debug=2"
      "user=colin:ipauth"
      # connect_timeout=10: casting shows to T.V. fails partway through about half the time
      "connect_timeout=20"
    ];
  };

  ifSshAuthorized = lib.mkIf config.sane.hosts.by-name."${config.networking.hostName}".ssh.authorized;

  remoteHome = name: { host ? name }: {
    sane.programs.sshfs-fuse.enableFor.system = true;
    system.fsPackages = [
      config.sane.programs.sshfs-fuse.package
    ];
    fileSystems."/mnt/${name}/home" = {
      device = "sshfs#colin@${host}:/home/colin";
      fsType = "fuse3";
      options = fsOpts.sshColin ++ fsOpts.lazyMount ++ [
        # drop_privileges: after `mount.fuse3` opens /dev/fuse, it will drop all capabilities before invoking sshfs
        "drop_privileges"
        "auto_unmount"  #< ensures that when the fs exits, it releases its mountpoint. then systemd can recognize it as failed.
      ];
      noCheck = true;
    };
    sane.fs."/mnt/${name}/home" = {
      dir.acl.user = "colin";
      dir.acl.group = "users";
      dir.acl.mode = "0700";
      wantedBy = [ "default.target" ];
      mount.depends = [ "network-online.target" ];
      mount.mountConfig.ExecSearchPath = [ "/run/current-system/sw/bin" ];
      mount.mountConfig.User = "colin";
      mount.mountConfig.AmbientCapabilities = "CAP_SETPCAP CAP_SYS_ADMIN";
      # hardening (systemd-analyze security mnt-desko-home.mount):
      # TODO: i can't use ProtectSystem=full here, because i can't create a new mount space; but...
      # with drop_privileges, i *could* sandbox the actual `sshfs` program using e.g. bwrap
      mount.mountConfig.CapabilityBoundingSet = "CAP_SETPCAP CAP_SYS_ADMIN";
      mount.mountConfig.LockPersonality = true;
      mount.mountConfig.MemoryDenyWriteExecute = true;
      mount.mountConfig.NoNewPrivileges = true;
      mount.mountConfig.ProtectClock = true;
      mount.mountConfig.ProtectHostname = true;
      mount.mountConfig.RemoveIPC = true;
      mount.mountConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
      #VVV this includes anything it reads from, e.g. /bin/sh; /nix/store/...
      # see `systemd-analyze filesystems` for a full list
      mount.mountConfig.RestrictFileSystems = "@common-block @basic-api fuse";
      mount.mountConfig.RestrictRealtime = true;
      mount.mountConfig.RestrictSUIDSGID = true;
      mount.mountConfig.SystemCallArchitectures = "native";
      mount.mountConfig.SystemCallFilter = [
        "@system-service"
        "@mount"
        "~@chown"
        "~@cpu-emulation"
        "~@keyring"
        # could remove almost all io calls, however one has to keep `open`, and `write`, to communicate with the fuse device.
        # so that's pretty useless as a way to prevent write access
      ];
      mount.mountConfig.IPAddressDeny = "any";
      mount.mountConfig.IPAddressAllow = "10.0.0.0/8";
      mount.mountConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
      mount.mountConfig.DeviceAllow = "/dev/fuse";
      # mount.mountConfig.RestrictNamespaces = true;  #< my sshfs sandboxing uses bwrap
    };
  };
  remoteServo = subdir: let
    localPath = "/mnt/servo/${subdir}";
    systemdName = utils.escapeSystemdPath localPath;
  in {
    sane.programs.curlftpfs.enableFor.system = true;
    system.fsPackages = [
      config.sane.programs.curlftpfs.package
    ];
    fileSystems."${localPath}" = {
      device = "curlftpfs#ftp://servo-hn:/${subdir}";
      noCheck = true;
      fsType = "fuse3";
      options = fsOpts.ftp ++ fsOpts.noauto ++ [
        # drop_privileges: after `mount.fuse3` opens /dev/fuse, it will drop all capabilities before invoking sshfs
        "drop_privileges"
        "auto_unmount"  #< ensures that when the fs exits, it releases its mountpoint. then systemd can recognize it as failed.
      ];
    };
    sane.fs."${localPath}" = {
      dir.acl.user = "colin";
      dir.acl.group = "users";
      dir.acl.mode = "0750";
      wantedBy = [ "default.target" ];
      mount.depends = [ "network-online.target" "${systemdName}-reachable.service" ];
      #VVV patch so that when the mount fails, we start a timer to remount it.
      #    and for a disconnection after a good mount (onSuccess), restart the timer to be more aggressive
      mount.unitConfig.OnFailure = [ "${systemdName}.timer" ];
      mount.unitConfig.OnSuccess = [ "${systemdName}-restart-timer.target" ];

      mount.mountConfig.TimeoutSec = "10s";
      mount.mountConfig.ExecSearchPath = [ "/run/current-system/sw/bin" ];
      mount.mountConfig.User = "colin";
      mount.mountConfig.AmbientCapabilities = "CAP_SETPCAP CAP_SYS_ADMIN";
      # hardening (systemd-analyze security mnt-servo-playground.mount)
      mount.mountConfig.CapabilityBoundingSet = "CAP_SETPCAP CAP_SYS_ADMIN";
      mount.mountConfig.LockPersonality = true;
      mount.mountConfig.MemoryDenyWriteExecute = true;
      mount.mountConfig.NoNewPrivileges = true;
      mount.mountConfig.ProtectClock = true;
      mount.mountConfig.ProtectHostname = true;
      mount.mountConfig.RemoveIPC = true;
      mount.mountConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
      #VVV this includes anything it reads from, e.g. /bin/sh; /nix/store/...
      # see `systemd-analyze filesystems` for a full list
      mount.mountConfig.RestrictFileSystems = "@common-block @basic-api fuse";
      mount.mountConfig.RestrictRealtime = true;
      mount.mountConfig.RestrictSUIDSGID = true;
      mount.mountConfig.SystemCallArchitectures = "native";
      mount.mountConfig.SystemCallFilter = [
        "@system-service"
        "@mount"
        "~@chown"
        "~@cpu-emulation"
        "~@keyring"
        # could remove almost all io calls, however one has to keep `open`, and `write`, to communicate with the fuse device.
        # so that's pretty useless as a way to prevent write access
      ];
      mount.mountConfig.IPAddressDeny = "any";
      mount.mountConfig.IPAddressAllow = "10.0.10.5";
      mount.mountConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
      mount.mountConfig.DeviceAllow = "/dev/fuse";
      # mount.mountConfig.RestrictNamespaces = true;
    };

    systemd.services."${systemdName}-reachable" = {
      serviceConfig.ExecSearchPath = [ "/run/current-system/sw/bin" ];
      serviceConfig.ExecStart = lib.escapeShellArgs [
        "curlftpfs"
        "ftp://servo-hn:/${subdir}"
        "/dev/null"
        "-o"
        (lib.concatStringsSep "," ([
          "exit_after_connect"
        ] ++ config.fileSystems."${localPath}".options))
      ];
      serviceConfig.RemainAfterExit = true;
      serviceConfig.Type = "oneshot";
      unitConfig.BindsTo = [ "${systemdName}.mount" ];
      # hardening (systemd-analyze security mnt-servo-playground-reachable.service)
      serviceConfig.AmbientCapabilities = "";
      serviceConfig.CapabilityBoundingSet = "";
      serviceConfig.DynamicUser = true;
      serviceConfig.LockPersonality = true;
      serviceConfig.MemoryDenyWriteExecute = true;
      serviceConfig.NoNewPrivileges = true;
      serviceConfig.PrivateDevices = true;
      serviceConfig.PrivateMounts = true;
      serviceConfig.PrivateTmp = true;
      serviceConfig.PrivateUsers = true;
      serviceConfig.ProcSubset = "all";
      serviceConfig.ProtectClock = true;
      serviceConfig.ProtectControlGroups = true;
      serviceConfig.ProtectHome = true;
      serviceConfig.ProtectKernelModules = true;
      serviceConfig.ProtectProc = "invisible";
      serviceConfig.ProtectSystem = "strict";
      serviceConfig.RemoveIPC = true;
      serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
      # serviceConfig.RestrictFileSystems = "@common-block @basic-api";  #< NOPE
      serviceConfig.RestrictRealtime = true;
      serviceConfig.RestrictSUIDSGID = true;
      serviceConfig.SystemCallArchitectures = "native";
      serviceConfig.SystemCallFilter = [
        "@system-service"
        "@mount"
        "~@chown"
        "~@cpu-emulation"
        "~@keyring"
        # "~@privileged"  #< NOPE
        "~@resources"
        # could remove some more probably
      ];
      serviceConfig.IPAddressDeny = "any";
      serviceConfig.IPAddressAllow = "10.0.10.5";
      serviceConfig.DevicePolicy = "closed";
      # exceptions
      serviceConfig.ProtectHostname = false;
      serviceConfig.ProtectKernelLogs = false;
      serviceConfig.ProtectKernelTunables = false;
    };

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
  };
in
lib.mkMerge [
  {
    # some services which use private directories error if the parent (/var/lib/private) isn't 700.
    sane.fs."/var/lib/private".dir.acl.mode = "0700";

    # in-memory compressed RAM
    # defaults to compressing at most 50% size of RAM
    # claimed compression ratio is about 2:1
    # - but on moby w/ zstd default i see 4-7:1  (ratio lowers as it fills)
    # note that idle overhead is about 0.05% of capacity (e.g. 2B per 4kB page)
    # docs: <https://www.kernel.org/doc/Documentation/blockdev/zram.txt>
    #
    # to query effectiveness:
    # `cat /sys/block/zram0/mm_stat`. whitespace separated fields:
    # - *orig_data_size*  (bytes)
    # - *compr_data_size* (bytes)
    # - mem_used_total    (bytes)
    # - mem_limit         (bytes)
    # - mem_used_max      (bytes)
    # - *same_pages*  (pages which are e.g. all zeros (consumes no additional mem))
    # - *pages_compacted*  (pages which have been freed thanks to compression)
    # - huge_pages  (incompressible)
    #
    # see also:
    # - `man zramctl`
    zramSwap.enable = true;
    # how much ram can be swapped into the zram device.
    # this shouldn't be higher than the observed compression ratio.
    # the default is 50% (why?)
    # 100% should be "guaranteed" safe so long as the data is even *slightly* compressible.
    # but it decreases working memory under the heaviest of loads by however much space the compressed memory occupies (e.g. 50% if 2:1; 25% if 4:1)
    zramSwap.memoryPercent = 100;

    programs.fuse.userAllowOther = true;  #< necessary for `allow_other` or `allow_root` options.
  }

  (ifSshAuthorized (remoteHome "crappy" {}))
  (ifSshAuthorized (remoteHome "desko" {}))
  (ifSshAuthorized (remoteHome "lappy" {}))
  (ifSshAuthorized (remoteHome "moby" { host = "moby-hn"; }))
  (ifSshAuthorized (remoteHome "servo" {}))
  # this granularity of servo media mounts is necessary to support sandboxing:
  # for flaky mounts, we can only bind the mountpoint itself into the sandbox,
  # so it's either this or unconditionally bind all of media/.
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

