{ config, pkgs, lib, inputs, materusFlake, ... }:
{
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  swapDevices = [
    {
      label = "NixOS_Swap";
    }
  ];





  fileSystems."/etc/nixos" =
    {
      device = "/materus/config/Nixerus";
      fsType = "none";
      options = [ "bind" ];
    };


  fileSystems."/materus" =
    {
      device = "/dev/disk/by-label/NixOS_Root";
      fsType = "btrfs";
      options = [ "subvol=@materus" "noatime" "compress=zstd" "ssd" "space_cache=v2" ];
    };

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NixOS_Root";
      fsType = "btrfs";
      options = [ "subvol=@" "noatime" "ssd" "space_cache=v2" "compress=zstd" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-label/NixOS_Root";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime" "compress=zstd" "ssd" "space_cache=v2" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-label/NixOS_Root";
      fsType = "btrfs";
      options = [ "subvol=@home" "noatime" "compress=zstd" "ssd" "space_cache=v2" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/NixOS_Root";
      fsType = "btrfs";
      options = [ "subvol=@boot" "ssd" ];
    };



  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-label/NixOS_EFI";
      fsType = "vfat";
    };

}
