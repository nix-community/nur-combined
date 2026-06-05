# use: `sudo zpool status`
# N.B.: the `sudo` part IS necessary, because of sandboxing.
# - sandboxing with landlock doesn't require `sudo`, though. i'd guess the zfs kernel module just isn't namespace aware or something.
{ pkgs, ... }:
{
  sane.programs.zfs-tools = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.zfs [
      "arc_summary"
      "arcstat"
      # "dbufstat"
      "zdb"
      "zfs"
      "zfs_ids_to_path"
      "zilstat"
      "zpool"
      "zstream"
      "zstreamdump"
    ];

    sandbox.tryKeepUsers = true;
    sandbox.extraPaths = [ "/dev" ];
  };
}
