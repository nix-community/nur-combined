{ pkgs, ... }:

let sshOpts = rec {
  fsType = "fuse.sshfs";
  optionsBase = [
    "x-systemd.automount"
    "_netdev"
    "user"
    "identityfile=/home/colin/.ssh/id_ed25519"
    "allow_other"
    "default_permissions"
  ];
  optionsColin = optionsBase ++ [
    "transform_symlinks"
    "idmap=user"
    "uid=1000"
    "gid=100"
  ];

  optionsRoot = optionsBase ++ [
    # we don't transform_symlinks because that breaks the validity of remote /nix stores
    "sftp_server=/run/wrappers/bin/sudo\\040/run/current-system/sw/libexec/sftp-server"
  ];
};
in
{
  environment.pathsToLink = [
    # needed to achieve superuser access for user-mounted filesystems (see optionsRoot above)
    # we can only link whole directories here, even though we're only interested in pkgs.openssh
    "/libexec"
  ];

  fileSystems."/mnt/servo-media-wan" = {
    device = "colin@uninsane.org:/var/lib/uninsane/media";
    inherit (sshOpts) fsType;
    options = sshOpts.optionsColin;
    noCheck = true;
  };
  fileSystems."/mnt/servo-media-lan" = {
    device = "colin@servo:/var/lib/uninsane/media";
    inherit (sshOpts) fsType;
    options = sshOpts.optionsColin;
    noCheck = true;
  };
  fileSystems."/mnt/servo-root-wan" = {
    device = "colin@uninsane.org:/";
    inherit (sshOpts) fsType;
    options = sshOpts.optionsRoot;
    noCheck = true;
  };
  fileSystems."/mnt/servo-root-lan" = {
    device = "colin@servo:/";
    inherit (sshOpts) fsType;
    options = sshOpts.optionsRoot;
    noCheck = true;
  };
  fileSystems."/mnt/desko-home" = {
    device = "colin@desko:/home/colin";
    inherit (sshOpts) fsType;
    options = sshOpts.optionsColin;
    noCheck = true;
  };
  fileSystems."/mnt/desko-root" = {
    device = "colin@desko:/";
    inherit (sshOpts) fsType;
    options = sshOpts.optionsRoot;
    noCheck = true;
  };

  environment.systemPackages = [
    pkgs.sshfs-fuse
  ];
}

