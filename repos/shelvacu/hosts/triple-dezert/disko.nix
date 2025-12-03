{ inputs, lib, ... }:
let
  megaHardDrives = [
    "ata-ST22000NM001E-3HM103_ZX201FM0"
    "ata-ST22000NM001E-3HM103_ZX203VCZ"
    "ata-ST22000NM001E-3HM103_ZX205FWT"
    "ata-ST22000NM001E-3HM103_ZX20DF5X"
    "ata-ST22000NM001E-3HM103_ZX20E46K"
    "ata-ST22000NM001E-3HM103_ZX20FE2V"
    "ata-ST22000NM001E-3HM103_ZX210E0K"
    "ata-ST22000NM001E-3HM103_ZX211AMH"
  ];
  bigSSDs = [
    "nvme-Samsung_SSD_990_PRO_with_Heatsink_2TB_S73HNJ0W805008X_1"
    "nvme-Seagate_IronWolf_ZP2000NM30002-2XW302_7QH01NJS_1"
    "nvme-WD_Red_SN700_2000GB_23284U800343_1"
  ];
  idToPath = id: "/dev/disk/by-id/${id}";
  singleHardDriveConfig = id: {
    type = "disk";
    device = idToPath id;
    content.type = "gpt";
    content.partitions.primary = {
      size = toString (42970624000 * 512);
      content = {
        type = "zfs";
        pool = "trip";
      };
    };
    content.partitions.padding = {
      size = toString (16384 * 512);
    };
  };
  rootMdName = "nixos:triple-dezert-md";
  singleSolidStateConfig = id: {
    # each disk is 2TB. Use 512GiB for root md, 1TiB for zfs stuff, and ~350GB remaining
    type = "disk";
    device = idToPath id;
    content.type = "gpt";
    content.partitions.root_part = {
      size = "512G";
      content.type = "mdraid";
      content.name = rootMdName;
    };
  };
  diskConfigs =
    (lib.genAttrs megaHardDrives singleHardDriveConfig)
    // (lib.genAttrs bigSSDs singleSolidStateConfig);
  datasets = [
    #devver-vm
    #ffuts
    #fw-backup
    #fw-backup-2
    "gitea-data"
    "ncdata"
    "nix-binary-cache"
    "pg"
    "pg/data"
    "pg/wal"
    #sqlites
  ];
in
{
  imports = [
    inputs.disko.nixosModules.disko
    {
      disko.devices.zpool.trip.datasets = lib.genAttrs datasets (_: {
        type = "zfs_fs";
      });
    }
  ];

  disko.devices.disk = diskConfigs;
  disko.devices.mdadm.${rootMdName} = {
    type = "mdadm";
    level = 1;
    content = {
      type = "filesystem";
      format = "f2fs";
      mountpoint = "/";
    };
  };
  disko.devices.zpool.trip = {
    type = "zpool";
    datasets."nix-binary-cache".type = "zfs_fs";
    datasets."nix-binary-cache".options = {
      recordsize = "16K";
      compression = "zstd";
      devices = "off";
      exec = "off";
    };
    datasets."pg".type = "zfs_fs";
    datasets."pg".options = {
      recordsize = "8K";
      dedup = "off";
    };
    datasets."pg/data".type = "zfs_fs";
    datasets."pg/data".options.logbias = "throughput";
  };
}
