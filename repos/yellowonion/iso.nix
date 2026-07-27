{ modulesPath, config, lib, pkgs, ... }:
{
  imports = [
   "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
   "${modulesPath}/installer/cd-dvd/channel.nix"
  ];
  isoImage.edition = "bchfs";
  boot.kernelPackages = lib.mkOverride 0 (pkgs.linuxPackagesFor pkgs.bcachefs-kernel);

  boot.supportedFilesystems = pkgs.lib.mkForce [ "bcachefs" "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
}
