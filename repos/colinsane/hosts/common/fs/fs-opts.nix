# docs
# - x-systemd options: <https://www.freedesktop.org/software/systemd/man/systemd.mount.html>
# - fuse options: `man mount.fuse`
rec {
  common = [
    "_netdev"
    "noatime"
    # user: allow any user with access to the device to mount the fs.
    #       note that this requires a suid `mount` binary; see: <https://zameermanji.com/blog/2022/8/5/using-fuse-without-root-on-linux/>
    "user"
    "x-systemd.requires=network-online.target"
    "x-systemd.after=network-online.target"
    "x-systemd.mount-timeout=10s"  # how long to wait for mount **and** how long to wait for unmount
    # disable defaults: don't fail local-fs.target if this mount fails
    "nofail"
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
    "drop_privileges"
    "auto_unmount"  #< ensures that when the fs exits, it releases its mountpoint. then systemd can recognize it as failed.
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
}
