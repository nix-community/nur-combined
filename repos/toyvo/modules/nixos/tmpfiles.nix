{ config, lib, ... }:
let
  cfg = config.systemd.tmpfiles.generateRules;
in
{
  options.systemd.tmpfiles.generateRules = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.int);
    default = { };
    description = "Attribute set of directory paths to lists of UIDs that should be granted rwx ACL access via systemd-tmpfiles.";
  };

  config.systemd.tmpfiles.rules = lib.mkIf (cfg != { }) (
    lib.concatLists (
      lib.mapAttrsToList (
        directory: uids:
        lib.concatMap (uid: [
          "a ${directory} - - - - u:${toString uid}:rwx,g::---,m::rwx"
          "A ${directory} - - - - u:${toString uid}:rwx,g::---,m::rwx"
        ]) uids
      ) cfg
    )
  );
}
