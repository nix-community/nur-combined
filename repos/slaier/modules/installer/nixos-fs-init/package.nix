{ lib, replaceVarsWith, btrfs-progs, coreutils, dosfstools, parted, mount, umount, ... }:
replaceVarsWith {
  src = ./nixos-fs-init.sh;
  dir = "bin";
  isExecutable = true;

  replacements = {
    path = lib.makeBinPath [
      btrfs-progs
      coreutils
      dosfstools
      parted
      mount
      umount
    ];
  };
}
