# Backup your data, kids!
{ config, lib, ... }:
let
  cfg = config.my.services.postgresql-backup;
in
{
  options.my.services.postgresql-backup = {
    enable = lib.mkEnableOption "Backup SQL databases";
  };

  config = lib.mkIf cfg.enable {
    services.postgresqlBackup = {
      enable = true;
      backupAll = true;
      location = "/var/backup/postgresql";
    };

    my.services.backup = {
      paths = [
        config.services.postgresqlBackup.location
      ];
      # No need to store previous backups thanks to `restic`
      exclude = [
        (config.services.postgresqlBackup.location + "/*.prev.sql.gz")
      ];
    };
  };
}
