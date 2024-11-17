{ config, lib, ... }:
let
  cfg = config.sane.programs.btrfs-progs;
in
{
  sane.programs.btrfs-progs = {
    sandbox.autodetectCliPaths = "existing";  # e.g. `btrfs filesystem df /my/fs`
    sandbox.extraPaths = [
      "/dev/btrfs-control"
      #vvv required for `sudo btrfs filesystem show` with no args
      "/dev"
      "/sys/block"
      "/sys/dev/block"
      "/sys/devices"
    ];
    sandbox.tryKeepUsers = true;
    sandbox.capabilities = [ "sys_admin" ];  # for `btrfs scrub`
  };

  # TODO: service sandboxing
  services.btrfs.autoScrub.enable = lib.mkIf cfg.enabled true;
  services.btrfs.autoScrub.interval = "weekly";
}

