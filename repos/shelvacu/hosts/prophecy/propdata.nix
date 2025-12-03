{
  lib,
  vaculib,
  inputs,
  config,
  ...
}:
let
  k = 1000;
  m = k * 1000;
  g = m * 1000;
  t = g * 1000;
  ki = 1024;
  safe_size =
    size:
    lib.pipe size [
      (n: n * 0.99) # leave 1% unused
      (n: n / (4 * ki)) # convert to sectors
      builtins.floor # integer number of sectors
      (n: n * (4 * ki)) # convert to bytes
    ];
  # I have drives that are 8TB, 10TB, and 14TB. By partitioning the 14TB into 8 + 2 + 4 and the 10TB into 8 + 2, I can create a vdevs across a bunch of 8TB, 2TB, and 4TB partitions
  slabsMin = {
    slabA = {
      idx = 0;
      sizeT = 8;
    };
    slabB = {
      idx = 1;
      sizeT = 2;
    };
    slabC = {
      idx = 2;
      sizeT = 4;
    };
  };
  slabs = lib.mapAttrs (
    name: value:
    value
    // rec {
      inherit name;
      sizeBytes = safe_size (value.sizeT * t);
      sizeKi = sizeBytes / ki;
      partitionConfig = {
        size = "${builtins.toString sizeKi}K";
        type = fs_type_zfs;
        priority = 1000 + value.idx;
        content = {
          type = "zfs";
          pool = poolname;
        };
      };
    }
  ) slabsMin;
  slabParts = lib.mapAttrs (_: v: v.partitionConfig) slabs;
  path_prefix = "/dev/disk/by-id/";
  # 8TB
  seagate_1 = "ata-ST8000DM004-2U9188_ZR115511";
  seagate_2 = "ata-ST8000DM004-2U9188_ZR11FWPR";
  seagates = [
    seagate_1
    seagate_2
  ];
  # 10TB
  easystore_1 = "ata-WDC_WD100EMAZ-00WJTA0_1EGEP22N";
  easystore_2 = "ata-WDC_WD100EMAZ-00WJTA0_1EGLWXMZ";
  easystores_10 = [
    easystore_1
    easystore_2
  ];
  # 14TB
  easystores_14 = vaculib.listOfLines { } ''
    # unused, previously nothing
    ata-WDC_WD140EDGZ-11B2DA2_2BHRSN3F
    ata-WDC_WD140EDGZ-11B2DA2_2CG19ERP
    ata-WDC_WD140EDGZ-11B2DA2_2CG4ZYSN
    ata-WDC_WD140EDGZ-11B2DA2_2CHTL49L
    ata-WDC_WD140EDGZ-11B2DA2_3WG0KG8K
    ata-WDC_WD140EDGZ-11B2DA2_3WG0LATM
    ata-WDC_WD140EDGZ-11B2DA2_3WH4KX0P
    ata-WDC_WD140EDGZ-11B2DA2_3WJ4XRUJ
    ata-WDC_WD140EDGZ-11B2DA2_3WK2HBDP

    # unused, previously cold spare for emanlooc
    ata-WDC_WD140EDFZ-11A0VA0_Y5J3929C

    # previously the emanlooc pool
    ata-WDC_WD140EDFZ-11A0VA0_9LG7AUEG
    ata-WDC_WD140EDFZ-11A0VA0_9LG8247A
    ata-WDC_WD140EDFZ-11A0VA0_9LG8475A
    ata-WDC_WD140EDFZ-11A0VA0_9LG872WA
    ata-WDC_WD140EDFZ-11A0VA0_9MG7KBWA
    ata-WDC_WD140EDFZ-11A0VA0_Y5J31ZAC
    ata-WDC_WD140EDFZ-11A0VA0_Y5J333UC
    ata-WDC_WD140EDFZ-11A0VA0_Y5J3V54C
  '';
  easystores_14_spare = lib.singleton (lib.head easystores_14);
  easystores_14_active = lib.tail easystores_14;
  fs_type_zfs = "a504"; # FreeBSD ZFS
  poolname = "propdata";

  diskName = groupName: id: "${groupName}_${lib.last (lib.splitString "_" id)}";
  mk_configs =
    {
      groupName,
      diskIds,
      partitions,
    }:
    vaculib.mapListToAttrs (id: {
      name = diskName groupName id;
      value = {
        type = "disk";
        device = path_prefix + id;
        content = {
          type = "gpt";
          inherit partitions;
        };
      };
    }) diskIds;
  groupAttrs = {
    es14a = {
      groupName = "es14a";
      diskIds = easystores_14_active;
      partitions = { inherit (slabParts) slabA slabB slabC; };
    };
    es14s = {
      groupName = "es14s";
      diskIds = easystores_14_spare;
      partitions = { inherit (slabParts) slabA slabB slabC; };
    };
    es10 = {
      groupName = "es10";
      diskIds = easystores_10;
      partitions = { inherit (slabParts) slabA slabB; };
    };
    sg8 = {
      groupName = "sg8";
      diskIds = seagates;
      partitions = { inherit (slabParts) slabA; };
    };
  };
  partNames =
    groupName: partName:
    map (
      id: config.disko.devices.disk.${diskName groupName id}.content.partitions.${partName}.device
    ) groupAttrs.${groupName}.diskIds;
in
{
  imports = [ inputs.disko.nixosModules.default ];
  options.vacu.prophecy = lib.mapAttrs (_: vaculib.mkOutOption) {
    inherit easystores_10 easystores_14 seagates;
  };
  config.disko = {
    enableConfig = false;
    checkScripts = true;
    rootMountPoint = "/";
    devices.disk =
      { }
      // mk_configs groupAttrs.es14a
      // mk_configs groupAttrs.es14s
      // mk_configs groupAttrs.es10
      // mk_configs groupAttrs.sg8;
    devices.zpool."${poolname}" = {
      type = "zpool";
      options = {
        ashift = "12";
        comment = "Shelvacu's, for prophecy server"; # comment is limited to 32 characters
        failmode = "continue";
      };
      rootFsOptions = {
        acltype = "posix";
        atime = "off";
        compression = "zstd";
        devices = "off";
        dedup = "on";
        dnodesize = "auto";
        encryption = "on";
        keyformat = "hex";
        keylocation = "file:///var/log/propdata-encryption-key.hex.txt";
        exec = "off";
        redundant_metadata = "most";
        xattr = "sa";
      };
      mode.topology = {
        type = "topology";
        vdev = [
          # slabA
          {
            mode = "raidz3";
            members = lib.concatMap (a: partNames a "slabA") [
              "sg8"
              "es10"
              "es14a"
            ];
          }
          # slabB
          {
            mode = "raidz3";
            members = lib.concatMap (a: partNames a "slabB") [
              "es10"
              "es14a"
            ];
          }
          # slabC
          {
            mode = "raidz3";
            members = partNames "es14a" "slabC";
          }
        ];
        spare = lib.concatMap (b: partNames "es14s" b) (builtins.attrNames slabs);
      };
    };
  };
  config.boot.zfs = {
    extraPools = [ poolname ];
    pools.${poolname}.devNodes = "/dev/disk/by-partlabel";
  };
}
