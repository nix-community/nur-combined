{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44445555-6666-7777-8888-999900001111";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2222-3333";
    fsType = "vfat";
  };
}
