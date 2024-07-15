{ pkgs, ... }:
{
  sane.programs.zfs-tools = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.zfs [
      "bin/arc_summary"
      "bin/arcstat"
      # "bin/dbufstat"
      "bin/zdb"
      "bin/zfs"
      "bin/zfs_ids_to_path"
      "bin/zilstat"
      "bin/zpool"
      "bin/zstream"
      "bin/zstreamdump"
    ];

    sandbox.method = "landlock";  #< bwrap doesn't work
    sandbox.extraPaths = [ "/dev" ];
  };
}
