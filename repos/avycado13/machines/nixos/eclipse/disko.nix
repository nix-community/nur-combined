{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";
    content = {
      type = "gpt";
      partitions = {
        # This VM currently boots via BIOS on a GPT disk. GRUB needs an EF02 partition.
        bios = {
          size = "3M";
          type = "EF02";
        };
        # Retain an ESP so the image can also boot if the provider switches to UEFI.
        ESP = {
          size = "124M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/efi";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
