# Backups using Backblaze B2 and `restic`
{ config, pkgs, lib, ... }:
let
  cfg = config.my.services.backup;

  excludeArg = with builtins; with pkgs; "--exclude-file=" +
    (writeText "excludes.txt" (concatStringsSep "\n" cfg.exclude));
in
{
  options.my.services.backup = with lib; {
    enable = mkEnableOption "Enable backups for this host";

    repository = mkOption {
      type = types.str;
      example = "/mnt/backup-hdd";
      description = "The repository to back up to";
    };

    passwordFile = mkOption {
      type = types.str;
      example = "/var/lib/restic/password.txt";
      description = "Read the repository's password from this path";
    };

    credentialsFile = mkOption {
      type = types.str;
      example = "/var/lib/restic/creds.env";
      description = ''
        Credential file as an 'EnvironmentFile' (see `systemd.exec(5)`)
      '';
    };

    paths = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [
        "/var/lib"
        "/home"
      ];
      description = "Paths to backup";
    };

    exclude = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [
        # very large paths
        "/var/lib/docker"
        "/var/lib/systemd"
        "/var/lib/libvirt"

        # temporary files created by `cargo` and `go build`
        "**/target"
        "/home/*/go/bin"
        "/home/*/go/pkg"
      ];
      description = "Paths to exclude from backup";
    };

    pruneOpts = mkOption {
      type = with types; listOf str;
      default = [
        "--keep-last 10"
        "--keep-hourly 24"
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 100"
      ];
      example = [ "--keep-last 5" "--keep-weekly 2" ];
      description = ''
        List of options to give to the `forget` subcommand after a backup.
      '';
    };

    timerConfig = mkOption {
      # NOTE: I do not know how to cleanly set the type
      default = {
        OnCalendar = "daily";
      };
      example = {
        OnCalendar = "00:05";
        RandomizedDelaySec = "5h";
      };
      description = ''
        When to run the backup. See man systemd.timer for details.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups.backblaze = {
      # Take care of included and excluded files
      paths = cfg.paths;
      extraBackupArgs = [ "--verbose=2" ]
        ++ lib.optional (builtins.length cfg.exclude != 0) excludeArg
      ;
      # Take care of creating the repository if it doesn't exist
      initialize = true;
      # give B2 API key securely
      environmentFile = cfg.credentialsFile;

      inherit (cfg) passwordFile pruneOpts timerConfig repository;
    };
  };
}
