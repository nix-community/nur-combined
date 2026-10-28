{ config, lib, ... }:

let
  cfg = config.services.zfs.optimization;
in
{
  options.services.zfs.optimization = {
    enable = lib.mkEnableOption "zfs tuning optimized for 3a games on hdd raid10 with nvme l2arc";

    arcMinGiB = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "minimum arc size in gib to prevent ram starvation";
    };

    arcMaxGiB = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = ''
        maximum arc size in gib (0 keeps `zfs_arc_max` unset, i.e. no cap).
        Without a cap ZFS is allowed to grow the ARC up to all of RAM, which on
        a box that also runs a large page-cache workload leaves the kernel in
        permanent direct reclaim / swap-out.
      '';
    };

    aggressiveL2ARC = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "uncap all l2arc throttling and disregard ssd write endurance";
    };

    disablePrefetch = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "disable kernel prefetcher to reduce random seek overhead on hdds";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModprobeConfig = ''
      # guarantee minimum l1 arc capacity
      options zfs zfs_arc_min=${toString (cfg.arcMinGiB * 1024 * 1024 * 1024)}
      ${lib.optionalString (cfg.arcMaxGiB > 0) ''
        # hard cap on the l1 arc so it cannot crowd out page cache and anon
        options zfs zfs_arc_max=${toString (cfg.arcMaxGiB * 1024 * 1024 * 1024)}
      ''}

      # disable vdev prefetch for random-access game packages
      options zfs zfs_prefetch_disable=${if cfg.disablePrefetch then "1" else "0"}

      ${lib.optionalString cfg.aggressiveL2ARC ''
        # ensure first-time reads (mru) are immediately ingested
        options zfs l2arc_mfuonly=0

        # saturate pcie 3.0 nvme write capability (1gib/s sustained, 2gib/s burst)
        options zfs l2arc_write_max=1073741824
        options zfs l2arc_write_boost=2147483648

        # scan memory queue deeper to feed l2arc without stalling
        options zfs l2arc_headroom=16
        options zfs l2arc_headroom_boost=32

        # wake up l2arc feed thread more frequently (every 50ms)
        options zfs l2arc_feed_min_ms=50
        options zfs l2arc_feed_again=1
      ''}
    '';
  };
}
