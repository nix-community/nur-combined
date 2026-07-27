{ config, ... }:
{
  disko.devices = {
    disk."${config.networking.hostName}" = {
      # Select 4096 byte LBA format: nvme format --lbaf=1 /dev/nvme0n1
      device = "/dev/disk/by-id/nvme-CT1000T500SSD5_2414484430DB";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "2G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "f2fs"; # NSFW...
              mountpoint = "/nix";
              extraArgs = [
                "-i" # More space for inodes: https://lore.kernel.org/all/CAF_dkJB%3d2PAqes+41xAi74Z3X0dSjQzCd9eMwDjpKmLD9PBq6A@mail.gmail.com/T/
                "-O"
                "encrypt,extra_attr,project_quota,inode_checksum,quota,lost_found,sb_checksum,compression"
              ];
              mountOptions = [
                "noatime"
                "gc_merge"
                "compress_algorithm=zstd:6"
                "compress_chksum"
                "compress_cache"
                "inlinecrypt"
                "atgc"
                "age_extent_cache"
              ];
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "noatime"
          "size=1G"
          "mode=755"
        ];
      };
    };
  };
}
