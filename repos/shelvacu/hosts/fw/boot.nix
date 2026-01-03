{ vaculib, ... }:
let
  bootMaskFile = vaculib.mask {
    all.read = "allow";
    user = {
      read = "allow";
      write = "allow";
    };
  };
  bootMaskDir = vaculib.mask {
    all = {
      read = "allow";
      write = "forbid";
      execute = "allow";
    };
    user = "allow";
  };
in
{
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    memtest86.enable = true;
    mirroredBoots = [
      {
        devices = [ "nodev" ];
        path = "/boot0";
      }
      {
        devices = [ "nodev" ];
        path = "/boot1";
      }
    ];
  };

  fileSystems."/boot0" = {
    device = "/dev/disk/by-label/BOOT0";
    fsType = "vfat";
    options = [
      "fmask=${bootMaskFile}"
      "dmask=${bootMaskDir}"
      "nofail"
    ];
  };

  fileSystems."/boot1" = {
    device = "/dev/disk/by-label/BOOT1";
    fsType = "vfat";
    options = [
      "fmask=${bootMaskFile}"
      "dmask=${bootMaskDir}"
      "nofail"
    ];
  };

}
