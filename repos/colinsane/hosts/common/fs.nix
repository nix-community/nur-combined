# docs
# - x-systemd options: <https://www.freedesktop.org/software/systemd/man/systemd.mount.html>
# - fuse options: `man mount.fuse`

{ lib, pkgs, sane-lib, ... }:

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
    # lazyMount: defer mounting until first access from userspace
    lazyMount = noauto ++ automount;
    wg = [
      "x-systemd.requires=wireguard-wg-home.service"
      "x-systemd.after=wireguard-wg-home.service"
    ];

    ssh = common ++ [
      "identityfile=/home/colin/.ssh/id_ed25519"
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
    sshColin = ssh ++ [
      # follow_symlinks: remote files which are symlinks are presented to the local system as ordinary files (as the target of the symlink).
      #                  if the symlink target does not exist, the presentation is unspecified.
      #                  symlinks which point outside the mount ARE followed. so this is more capable than `transform_symlinks`
      "follow_symlinks"
      # symlinks on the remote fs which are absolute paths are presented to the local system as relative symlinks pointing to the expected data on the remote fs.
      # only symlinks which would point inside the mountpoint are translated.
      "transform_symlinks"
      "idmap=user"
      "uid=1000"
      "gid=100"
    ];
    sshRoot = ssh ++ [
      # we don't transform_symlinks because that breaks the validity of remote /nix stores
      "sftp_server=/run/wrappers/bin/sudo\\040/run/current-system/sw/libexec/sftp-server"
    ];
    # in the event of hunt NFS mounts, consider:
    # - <https://unix.stackexchange.com/questions/31979/stop-broken-nfs-mounts-from-locking-a-directory>

    # NFS options: <https://linux.die.net/man/5/nfs>
    # actimeo=n  = how long (in seconds) to cache file/dir attributes (default: 3-60s)
    # bg         = retry failed mounts in the background
    # retry=n    = for how many minutes `mount` will retry NFS mount operation
    # soft       = on "major timeout", report I/O error to userspace
    # retrans=n  = how many times to retry a NFS request before giving userspace a "server not responding" error (default: 3)
    # timeo=n    = number of *deciseconds* to wait for a response before retrying it (default: 600)
    #              note: client uses a linear backup, so the second request will have double this timeout, then triple, etc.
    nfs = common ++ [
      # "actimeo=10"
      "bg"
      "retrans=4"
      "retry=0"
      "soft"
      "timeo=15"
      "nofail"  # don't fail remote-fs.target when this mount fails  (not an option for sshfs else would be common)
    ];
  };
  remoteHome = host: {
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

    # fileSystems."/mnt/servo-nfs" = {
    #   device = "servo-hn:/";
    #   noCheck = true;
    #   fsType = "nfs";
    #   options = fsOpts.nfs ++ fsOpts.automount ++ fsOpts.wg;
    # };
    fileSystems."/mnt/servo/media" = {
      device = "servo-hn:/media";
      noCheck = true;
      fsType = "nfs";
      options = fsOpts.nfs ++ fsOpts.lazyMount ++ fsOpts.wg;
    };
    sane.fs."/mnt/servo/media" = sane-lib.fs.wanted {
      dir.acl.user = "colin";
      dir.acl.group = "users";
      dir.acl.mode = "0750";
    };
    fileSystems."/mnt/servo/playground" = {
      device = "servo-hn:/playground";
      noCheck = true;
      fsType = "nfs";
      options = fsOpts.nfs ++ fsOpts.lazyMount ++ fsOpts.wg;
    };
    sane.fs."/mnt/servo/playground" = sane-lib.fs.wanted {
      dir.acl.user = "colin";
      dir.acl.group = "users";
      dir.acl.mode = "0750";
    };

    environment.pathsToLink = [
      # needed to achieve superuser access for user-mounted filesystems (see optionsRoot above)
      # we can only link whole directories here, even though we're only interested in pkgs.openssh
      "/libexec"
    ];

    programs.fuse.userAllowOther = true;  #< necessary for `allow_other` or `allow_root` options.
    environment.systemPackages = [
      pkgs.sshfs-fuse
    ];
  }

  (remoteHome "desko")
  (remoteHome "lappy")
  (remoteHome "moby")
]

