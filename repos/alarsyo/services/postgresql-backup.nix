{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.services.postgresql-backup;
in {
  options.my.services.postgresql-backup = {
    enable =
      (mkEnableOption "Backup SQL databases")
      // {default = config.services.postgresql.enable;};
  };

  config = mkIf cfg.enable {
    services.postgresqlBackup = {
      enable = true;
      # Restic backup starts at midnight so create DB dump just before
      startAt = "*-*-* 23:30:00";
    };

    my.services.restic-backup = mkIf cfg.enable {
      paths = ["/var/backup/postgresql"];

      # no need to store previously backed up files, as borg does the snapshoting
      # for us
      exclude = ["/var/backup/postgresql/*.prev.sql.gz"];
    };
  };
}
