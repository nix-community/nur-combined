{ lib, config, ... }:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.services.nextcloud.enable {
    users.users.nextcloud.extraGroups = [ "admin-password" ];
    services.nextcloud = {
      hostName = "nextcloud.${config.networking.hostName}.${config.networking.domain}";
      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        adminuser = "lucasew";
        adminpassFile = "/var/run/secrets/admin-password";
      };
    };

    systemd.services.nextcloud-setup = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };

    services.postgresqlBackup.databases = [ "nextcloud" ];

    services.postgresql = {
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {name = "nextcloud"; ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";}
      ];
    };
  };
}
