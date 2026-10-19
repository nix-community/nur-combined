# Shared submodule type for a service's `data` option: what a service needs
# backed up in order to be restored on any host. Declared once here and
# imported by both individual services and homelab/services/restic, which
# collects every `homelab.services.<name>.data` and auto-generates a restic
# backup job for it.
{ lib }:
lib.types.submodule {
  options = {
    sqlite = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to this service's sqlite database file. Checkpointed
        (PRAGMA wal_checkpoint(TRUNCATE)) before backup so the copy on disk
        isn't mid-write; the file's containing directory is backed up.
      '';
    };
    postgres = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Name of a local PostgreSQL database owned by this service. Dumped
        with pg_dump to a temp file and that dump is backed up, instead of
        the raw data directory which restic could otherwise capture
        mid-write.
      '';
    };
    files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional paths (files or directories) to back up as-is";
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "restic --exclude glob patterns";
    };
    stopUnits = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "systemd units to stop for the backup; defaults to the service's own unit name";
    };
    stopForBackup = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Stop stopUnits for the duration of the backup for a fully
        consistent snapshot. A failed stop degrades to a hot (best-effort)
        backup rather than skipping the run -- a stuck unit name here must
        never silently disable a service's backups.
      '';
    };
  };
}
