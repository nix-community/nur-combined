{ lib, replaceVarsWith, btrfs-progs, coreutils, mount, umount, ... }:
replaceVarsWith {
  src = ./nixos-fs-mount.sh;
  dir = "bin";
  isExecutable = true;

  replacements = {
    path = lib.makeBinPath [
      btrfs-progs
      coreutils
      mount
      umount
    ];
  };
}
