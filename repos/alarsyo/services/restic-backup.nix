{ config, lib, pkgs, ... }:

let
  inherit (lib)
    attrsets
    concatStringsSep
    mkEnableOption
    mkIf
    mkOption
    optional
  ;

  cfg = config.my.services.restic-backup;
  secrets = config.my.secrets;
  excludeArg = "--exclude-file=" + (pkgs.writeText "excludes.txt" (concatStringsSep "\n" cfg.exclude));
  makePruneOpts = pruneOpts:
    attrsets.mapAttrsToList (name: value: "--keep-${name} ${toString value}") pruneOpts;
in {
  options.my.services.restic-backup = let inherit (lib) types; in {
    enable = mkEnableOption "Enable Restic backups for this host";

    repo = mkOption {
      type = types.str;
      default = null;
      example = "/mnt/hdd";
      description = "Restic backup repo";

    };

    paths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "/var/lib"
        "/home"
      ];
      description = "Paths to backup";
    };

    exclude = mkOption {
      type = types.listOf types.str;
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

    prune = mkOption {
      type = types.attrs;
      default = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.restic ];

    services.restic.backups.backblaze = {
      initialize = true;

      paths = cfg.paths;

      repository = cfg.repo;
      passwordFile = "/root/restic/password";
      environmentFile = "/root/restic/creds";

      extraBackupArgs = [ "--verbose=2" ]
                        ++ optional (builtins.length cfg.exclude != 0) excludeArg;

      timerConfig = {
        OnCalendar = "daily";
      };

      pruneOpts = makePruneOpts cfg.prune;
    };
  };
}
