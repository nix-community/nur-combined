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

    sandbox.method = "landlock";  #< bwrap doesn't work
    sandbox.extraPaths = [ "/dev" ];
  };
}
