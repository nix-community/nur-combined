{ config, lib, ... }:
let
  cfg = config.fileSystemPresets;
in
{
  options.fileSystemPresets = {
    sd.enable = lib.mkEnableOption "SD card image partition ext4";
    boot.enable = lib.mkEnableOption "boot partition";
    btrfs.enable = lib.mkEnableOption "root btrfs partition";
    btrfs.extras.enable = lib.mkEnableOption "var and tmp btrfs partition";
    efi.enable = lib.mkEnableOption "efi partition";
    ext4.enable = lib.mkEnableOption "root ext4 partition";
  };

  config = {
    fileSystemPresets.ext4 = lib.mkIf cfg.sd.enable {
      enable = true;
    };

    fileSystems = {
      "/" = lib.mkIf (cfg.btrfs.enable || cfg.ext4.enable) {
        device = if cfg.sd.enable then "/dev/disk/by-label/NIXOS_SD" else "/dev/disk/by-label/NIXOS";
        fsType = if cfg.ext4.enable then "ext4" else "btrfs";
        options = lib.mkIf cfg.btrfs.enable [ "subvol=@" ];
      };

      "/boot/efi" = lib.mkIf cfg.efi.enable {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
      };

      "/home" = lib.mkIf cfg.btrfs.enable {
        device = "/dev/disk/by-label/NIXOS";
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };

      "/nix" = lib.mkIf cfg.btrfs.enable {
        device = "/dev/disk/by-label/NIXOS";
        fsType = "btrfs";
        options = [ "subvol=@nix" ];
      };

      "/tmp" = lib.mkIf (cfg.btrfs.enable && cfg.btrfs.extras.enable) {
        device = "/dev/disk/by-label/NIXOS";
        fsType = "btrfs";
        options = [ "subvol=@tmp" ];
      };

      "/var" = lib.mkIf (cfg.btrfs.enable && cfg.btrfs.extras.enable) {
        device = "/dev/disk/by-label/NIXOS";
        fsType = "btrfs";
        options = [ "subvol=@var" ];
      };

      "/boot" = lib.mkIf cfg.boot.enable {
        device = "/dev/disk/by-label/BOOT";
        fsType = "vfat";
      };
    };

    boot.loader.efi.efiSysMountPoint = lib.mkIf cfg.efi.enable "/boot/efi";
  };
}
