{ config, lib, ... }:
let
  cfg = config.sane.programs.btrfs-progs;
in
{
  sane.programs.btrfs-progs = {
    # sandbox.autodetectCliPaths = "existing";  # e.g. `btrfs filesystem df /my/fs`
    sandbox.autodetectCliPaths = "parent";  # e.g. `btrfs subvolume create ./my_subvol`
    sandbox.extraPaths = [
      "/dev/btrfs-control"
      #vvv required for `sudo btrfs filesystem show` with no args
      "/dev"
      "/sys/block"
      "/sys/dev/block"
      "/sys/devices"
      #vvv required for `sudo btrfs scrub start`
      "/sys/fs"
      #vvv required for `sudo btrfs scrub status` to show stats
      "/var/lib/btrfs"
    ];
    sandbox.tryKeepUsers = true;
    sandbox.keepPids = true;  # required for `sudo btrfs scrub start`
    sandbox.capabilities = [
      "dac_read_search"  # for `btrfs replace`
      "sys_admin"  # for `btrfs scrub`
    ];
  };

  # TODO: service sandboxing
  services.btrfs.autoScrub.enable = lib.mkIf cfg.enabled true;
  services.btrfs.autoScrub.interval = "weekly";
}

