{
  lib,
  config,
  global,
  ...
}:
{
  options = {
    services.postgresql.userSpecificDatabases = lib.mkOption {
      description = lib.mdDoc "Extra databases and users for specific reasons";

      type = with lib.types; attrsOf (listOf str);

      # $user_$database for all databases + $user so psql works out of the box 
      # one will still need to set passwords for users
      apply = lib.mapAttrs (k: v: (map (item: "${k}_${item}") v) ++ [ k ]);
    };
  };
  config = lib.mkIf config.services.postgresql.enable {

    services.postgresqlBackup = {
      enable = true;
      databases = [ "postgres" ];
    };

    services.postgresql = {
      authentication = lib.concatStringsSep "\n" (
        map (item: ''
          host  all all ${item.ts}/32      md5
        '') (lib.attrValues global.nodeIps)
      );

      ensureDatabases = lib.flatten (lib.attrValues config.services.postgresql.userSpecificDatabases);
      # TODO: fix the dropped module
      # ensureUsers = (map ({name, value}: {
      #   inherit name;
      #   ensurePermissions = lib.listToAttrs (map (database: {
      #     name = "${database}.*";
      #     value = "ALL PRIVILEGES";
      #   }) value);
      # ensureClauses = {
      #   login = true;
      # };

      # }) (lib.attrsToList config.services.postgresql.userSpecificDatabases));
    };
  };
}
