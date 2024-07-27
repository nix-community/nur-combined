{
  disko.devices.disk.vdb = {
    device = "/dev/disk/by-id/nvme-SAMSUNG_MZVL2256HCHQ-00BH1_S63XNX0RC21761";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "1G";
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
            format = "f2fs";
            mountpoint = "/";
            extraArgs = [
              "-O"
              "encrypt,extra_attr,inode_checksum,flexible_inline_xattr,inode_crtime,lost_found,sb_checksum,compression"
            ];
            mountOptions = [
              "gc_merge"
              "inline_xattr"
              "inline_data"
              "inline_dentry"
              "flush_merge"
              "extent_cache"
              "checkpoint_merge"
              "compress_algorithm=zstd"
              "compress_cache"
              "atgc"
            ];
          };
        };
      };
    };
  };
}

