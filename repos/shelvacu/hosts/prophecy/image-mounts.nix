{ vaculib, ... }:
{
  fileSystems."/archived-drives/rob-anime-seagate-8t/p2" =
    let
      # from `fdisk -u sectors -l disk.img
      startSector = 264192;
      startByte = startSector * 512;
      sizeSector = 15627788288;
      sizeByte = sizeSector * 512;
    in
    {
      device = "/propdata/drive-images/seagate-expansion-8tb/disk.img";
      noCheck = true;
      fsType = "ntfs";
      options = [
        "ro"
        "loop"
        "offset=${toString startByte}"
        "sizelimit=${toString sizeByte}"
        "x-systemd.requires=zfs-mount.service"
        "x-mount.mkdir"
        "nofail"
        "fmask=${vaculib.mask { all.read = "allow"; }}"
        "dmask=${
          vaculib.mask {
            all = {
              read = "allow";
              execute = "allow";
            };
          }
        }"
      ];
    };

  fileSystems."/propdata/media/disorganized/rob-anime-drive" = {
    device = "/archived-drives/rob-anime-seagate-8t/p2";
    options = [
      "bind"
      "x-mount.mkdir"
      "nofail"
    ];
  };
}
