# Ephemeral disk layout for Protectli router
# Root on tmpfs, /nix and /persistent on btrfs subvolumes
# WARNING: Applying this requires reinstallation via `disko-install`.
# Do NOT run `nixos-rebuild switch` with this imported on a live system.

{ ... }:

{
  disko.devices = {
    disk.main = {
      # Protectli Vaults typically use SATA SSD (msata or M.2 SATA)
      # Use `lsblk` on the target to confirm device name.
      # Common values: /dev/sda (SATA), /dev/nvme0n1 (NVMe)
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02"; # BIOS boot partition
          };
          ESP = {
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [
                "-n"
                "BOOT"
              ];
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "-L"
                "NIXOS"
              ];
              subvolumes = {
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/persistent" = {
                  mountpoint = "/persistent";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "mode=755"
      ];
    };
  };
}
