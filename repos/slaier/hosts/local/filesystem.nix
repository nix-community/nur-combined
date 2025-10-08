{ config, ... }:
{
  fileSystems = {
    "/" = {
      label = "${config.networking.hostName}-nixos";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=root" ];
    };
    "/nix" = {
      label = "${config.networking.hostName}-nixos";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" "subvol=nix" ];
    };
    "/swap" = {
      label = "${config.networking.hostName}-nixos";
      fsType = "btrfs";
      options = [ "noatime" "subvol=swap" ];
    };
    "/boot" = {
      label = "${config.networking.hostName}-boot";
      fsType = "vfat";
      options = [ "umask=077" ];
    };
  };
}
