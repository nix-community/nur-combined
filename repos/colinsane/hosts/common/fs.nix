# docs
# - x-systemd options: <https://www.freedesktop.org/software/systemd/man/systemd.mount.html>
# - fuse options: `man mount.fuse`

{ config, lib, pkgs, sane-lib, utils, ... }:

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
    wg = [
      "x-systemd.requires=wireguard-wg-home.service"
      "x-systemd.after=wireguard-wg-home.service"
    ];

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

    ssh = common ++ fuse ++ [
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
    # in the event of hunt NFS mounts, consider:
    # - <https://unix.stackexchange.com/questions/31979/stop-broken-nfs-mounts-from-locking-a-directory>

    # NFS options: <https://linux.die.net/man/5/nfs>
    # actimeo=n  = how long (in seconds) to cache file/dir attributes (default: 3-60s)
    # bg         = retry failed mounts in the background
    # retry=n    = for how many minutes `mount` will retry NFS mount operation
    # intr       = allow Ctrl+C to abort I/O (it will error with `EINTR`)
    # soft       = on "major timeout", report I/O error to userspace
    # softreval  = on "major timeout", service the request using known-stale cache results instead of erroring -- if such cache data exists
    # retrans=n  = how many times to retry a NFS request before giving userspace a "server not responding" error (default: 3)
    # timeo=n    = number of *deciseconds* to wait for a response before retrying it (default: 600)
    #              note: client uses a linear backup, so the second request will have double this timeout, then triple, etc.
    # proto=udp  = encapsulate protocol ops inside UDP packets instead of a TCP session.
    #              requires `nfsvers=3` and a kernel compiled with `NFS_DISABLE_UDP_SUPPORT=n`.
    #              UDP might be preferable to TCP because the latter is liable to hang for ~100s (kernel TCP timeout) after a link drop.
    #              however, even UDP has issues with `umount` hanging.
    #
    # N.B.: don't change these without first testing the behavior of sandboxed apps on a flaky network.
    nfs = common ++ [
      # "actimeo=5"
      # "bg"
      "retrans=1"
      "retry=0"
      # "intr"
      "soft"
      "softreval"
      "timeo=30"
      "nofail"  # don't fail remote-fs.target when this mount fails  (not an option for sshfs else would be common)
      # "proto=udp"  # default kernel config doesn't support NFS over UDP: <https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1964093> (see comment 11).
      # "nfsvers=3"  # NFSv4+ doesn't support UDP at *all*. it's ok to omit nfsvers -- server + client will negotiate v3 based on udp requirement. but omitting causes confusing mount errors when the server is *offline*, because the client defaults to v4 and thinks the udp option is a config error.
      # "x-systemd.idle-timeout=10"  # auto-unmount after this much inactivity
    ];

    # manually perform a ftp mount via e.g.
    #   curlftpfs -o ftpfs_debug=2,user=anonymous:anonymous,connect_timeout=10 -f -s ftp://servo-hn /mnt/my-ftp
    ftp = common ++ fuseColin ++ [
      # "ftpfs_debug=2"
      "user=colin:ipauth"
      "connect_timeout=10"
    ];
  };
  remoteHome = host: {
    sane.programs.sshfs-fuse.enableFor.system = true;
    fileSystems."/mnt/${host}/home" = {
      device = "colin@${host}:/home/colin";
      fsType = "fuse.sshfs";
      options = fsOpts.sshColin ++ fsOpts.lazyMount;
      noCheck = true;
    };
    sane.fs."/mnt/${host}/home" = sane-lib.fs.wanted {
      dir.acl.user = "colin";
      dir.acl.group = "users";
      dir.acl.mode = "0700";
    };
  };
  remoteServo = subdir: {
    sane.programs.curlftpfs.enableFor.system = true;
    sane.fs."/mnt/servo/${subdir}" = sane-lib.fs.wanted {
      dir.acl.user = "colin";
      dir.acl.group = "users";
      dir.acl.mode = "0750";
    };
    fileSystems."/mnt/servo/${subdir}" = {
      device = "ftp://servo-hn:/${subdir}";
      noCheck = true;
      fsType = "fuse.curlftpfs";
      options = fsOpts.ftp ++ fsOpts.noauto ++ fsOpts.wg;
      # fsType = "nfs";
      # options = fsOpts.nfs ++ fsOpts.lazyMount ++ fsOpts.wg;
    };
    systemd.services."automount-servo-${utils.escapeSystemdPath subdir}" = let
      fs = config.fileSystems."/mnt/servo/${subdir}";
    in {
      # this is a *flaky* network mount, especially on moby.
      # if done as a normal autofs mount, access will eternally block when network is dropped.
      # notably, this would block *any* sandboxed app which allows media access, whether they actually try to use that media or not.
      # a practical solution is this: mount as a service -- instead of autofs -- and unmount on timeout error, in a restart loop.
      # until the ftp handshake succeeds, nothing is actually mounted to the vfs, so this doesn't slow down any I/O when network is down.
      description = "automount /mnt/servo/${subdir} in a fault-tolerant and non-blocking manner";
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      wantedBy = [ "default.target" ];

      serviceConfig.Type = "simple";
      serviceConfig.ExecStart = lib.escapeShellArgs [
        "/usr/bin/env"
        "PATH=/run/current-system/sw/bin"
        "mount.${fs.fsType}"
        "-f"  # foreground (i.e. don't daemonize)
        "-s"  # single-threaded (TODO: it's probably ok to disable this?)
        "-o"
        (lib.concatStringsSep "," (lib.filter (o: !lib.hasPrefix "x-systemd." o) fs.options))
        fs.device
        "/mnt/servo/${subdir}"
      ];
      # not sure if this configures a linear, or exponential backoff.
      # but the first restart will be after `RestartSec`, and the n'th restart (n = RestartSteps) will be RestartMaxDelaySec after the n-1'th exit.
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = "10s";
      serviceConfig.RestartMaxDelaySec = "120s";
      serviceConfig.RestartSteps = "5";
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

    # environment.pathsToLink = [
    #   # needed to achieve superuser access for user-mounted filesystems (see sshRoot above)
    #   # we can only link whole directories here, even though we're only interested in pkgs.openssh
    #   "/libexec"
    # ];

    programs.fuse.userAllowOther = true;  #< necessary for `allow_other` or `allow_root` options.
  }

  (remoteHome "desko")
  (remoteHome "lappy")
  (remoteHome "moby")
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

