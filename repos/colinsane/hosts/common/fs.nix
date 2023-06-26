# docs
# - x-systemd options: <https://www.freedesktop.org/software/systemd/man/systemd.mount.html>

{ pkgs, sane-lib, ... }:

let fsOpts = rec {
  common = [
    "_netdev"
    "noatime"
    "x-systemd.requires=network-online.target"
    "x-systemd.after=network-online.target"
    "x-systemd.mount-timeout=10s"  # how long to wait for mount **and** how long to wait for unmount
  ];
  auto = [ "x-systemd.automount" ];
  noauto = [ "noauto" ];  # don't mount as part of remote-fs.target
  wg = [
    "x-systemd.requires=wireguard-wg-home.service"
    "x-systemd.after=wireguard-wg-home.service"
  ];

  ssh = common ++ [
    "user"
    "identityfile=/home/colin/.ssh/id_ed25519"
    "allow_other"
    "default_permissions"
  ];
  sshColin = ssh ++ [
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
in
{
  # fileSystems."/mnt/servo-nfs" = {
  #   device = "servo-hn:/";
  #   noCheck = true;
  #   fsType = "nfs";
  #   options = fsOpts.nfs ++ fsOpts.auto ++ fsOpts.wg;
  # };
  fileSystems."/mnt/servo-nfs/media" = {
    device = "servo-hn:/media";
    noCheck = true;
    fsType = "nfs";
    options = fsOpts.nfs ++ fsOpts.auto ++ fsOpts.wg;
  };
  # fileSystems."/mnt/servo-media-nfs" = {
  #   device = "servo-hn:/media";
  #   noCheck = true;
  #   fsType = "nfs";
  #   options = fsOpts.common ++ fsOpts.auto;
  # };
  sane.fs."/mnt/servo-media" = sane-lib.fs.wantedSymlinkTo "/mnt/servo-nfs/media";

  fileSystems."/mnt/servo-media-wan" = {
    device = "colin@uninsane.org:/var/lib/uninsane/media";
    fsType = "fuse.sshfs";
    options = fsOpts.sshColin ++ fsOpts.noauto;
    noCheck = true;
  };
  sane.fs."/mnt/servo-media-wan" = sane-lib.fs.wantedDir;
  fileSystems."/mnt/servo-media-lan" = {
    device = "colin@servo:/var/lib/uninsane/media";
    fsType = "fuse.sshfs";
    options = fsOpts.sshColin ++ fsOpts.noauto;
    noCheck = true;
  };
  sane.fs."/mnt/servo-media-lan" = sane-lib.fs.wantedDir;
  fileSystems."/mnt/servo-root-wan" = {
    device = "colin@uninsane.org:/";
    fsType = "fuse.sshfs";
    options = fsOpts.sshRoot ++ fsOpts.noauto;
    noCheck = true;
  };
  sane.fs."/mnt/servo-root-wan" = sane-lib.fs.wantedDir;
  fileSystems."/mnt/servo-root-lan" = {
    device = "colin@servo:/";
    fsType = "fuse.sshfs";
    options = fsOpts.sshRoot ++ fsOpts.noauto;
    noCheck = true;
  };
  sane.fs."/mnt/servo-root-lan" = sane-lib.fs.wantedDir;
  fileSystems."/mnt/desko-home" = {
    device = "colin@desko:/home/colin";
    fsType = "fuse.sshfs";
    options = fsOpts.sshColin ++ fsOpts.noauto;
    noCheck = true;
  };
  sane.fs."/mnt/desko-home" = sane-lib.fs.wantedDir;
  fileSystems."/mnt/desko-root" = {
    device = "colin@desko:/";
    fsType = "fuse.sshfs";
    options = fsOpts.sshRoot ++ fsOpts.noauto;
    noCheck = true;
  };
  sane.fs."/mnt/desko-root" = sane-lib.fs.wantedDir;

  environment.pathsToLink = [
    # needed to achieve superuser access for user-mounted filesystems (see optionsRoot above)
    # we can only link whole directories here, even though we're only interested in pkgs.openssh
    "/libexec"
  ];

  environment.systemPackages = [
    pkgs.sshfs-fuse
  ];
}

