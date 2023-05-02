{pkgs, config, lib, ...}:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.vps.pgbackup;
in
{
  options = {
    vps.pgbackup = {
      enable = mkEnableOption "Enable postgres backups";
      localFolder = mkOption {
        type = types.path;
        description = "Where to store the local backups";
        default = "/backups/postgres";
      };
    };
  };
  config = {
    services.postgresqlBackup = {
      enable = cfg.enable;
      backupAll = true;
      location = cfg.localFolder;
    };
  };
}
