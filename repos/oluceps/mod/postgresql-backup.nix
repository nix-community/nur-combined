{
  flake.modules.nixos.postgresql-backup = {
    services.postgresqlBackup = {
      enable = true;
      location = "/var/lib/backup/postgresql";
      compression = "none"; # rustix handle this
      startAt = "*-*-* 0,12:00:00";
      pgdumpAllOptions = "--exclude-database=relation";
    };
  };
}
