{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    attrsets
    concatStringsSep
    mkEnableOption
    mkIf
    mkOption
    optional
    ;

  cfg = config.my.services.restic-backup;
  excludeArg = "--exclude-file=" + (pkgs.writeText "excludes.txt" (concatStringsSep "\n" cfg.exclude));
  makePruneOpts = pruneOpts:
    attrsets.mapAttrsToList (name: value: "--keep-${name} ${toString value}") pruneOpts;
in {
  options.my.services.restic-backup = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Enable Restic backups for this host";

    repo = mkOption {
      type = types.str;
      default = null;
      example = "/mnt/hdd";
      description = "Restic backup repo";
    };

    paths = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [
        "/var/lib"
        "/home"
      ];
      description = "Paths to backup";
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = [];
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

    passwordFile = mkOption {
      type = types.str;
      default = "/root/restic/password";
    };

    environmentFile = mkOption {
      type = types.str;
      default = "/root/restic/creds";
    };

    timerConfig = mkOption {
      type = types.attrsOf types.str;
      default = {
        OnCalendar = "daily";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.restic];

    services.restic.backups.backblaze = {
      initialize = true;

      paths = cfg.paths;

      repository = cfg.repo;
      passwordFile = cfg.passwordFile;
      environmentFile = cfg.environmentFile;

      extraBackupArgs =
        ["--verbose=1"]
        ++ optional (builtins.length cfg.exclude != 0) excludeArg;

      timerConfig = cfg.timerConfig;

      pruneOpts = makePruneOpts cfg.prune;
    };
  };
}
