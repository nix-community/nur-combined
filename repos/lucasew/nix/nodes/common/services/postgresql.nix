{ lib, config, ... }:
{
  options = {
    services.postgresql.testDatabases = lib.mkOption {
      description = lib.mdDoc "Extra databases to be created and granted to the test user. Shouldn't contain production data and will be prefixed with `test_`";
      type = with lib.types; listOf str;
      apply = items: (map (item: "test_${item}") items) ++ ["test"];
      default = [];
    };
  };
  config = lib.mkIf config.services.postgresql.enable {
    services.postgresqlBackup = {
      enable = true;
      databases = [ "postgres" ];
    };

    services.postgresql = {
      ensureDatabases = config.services.postgresql.testDatabases;
      ensureUsers = (map (db: {
        name = "test";
        ensurePermissions = {
          "DATABASE \"${db}\"" = "ALL PRIVILEGES";
        };
        ensureClauses = {
          login = true;
        };
      }) config.services.postgresql.testDatabases);
    };
  };
}
