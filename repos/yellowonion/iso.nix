{ config, lib, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];
  isoImage.edition = "bchfs";
  boot.kernelPackages = lib.mkOverride 0 (pkgs.linuxPackagesFor pkgs.bcachefs-master);

  boot.supportedFilesystems = pkgs.lib.mkForce [ "bcachefs" "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
}
