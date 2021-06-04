{ config, lib, pkgs, ... }:

with lib;

let cfg = config.my.services.borg-backup;
in {
  options.my.services.borg-backup = {
    enable = mkEnableOption "Enable Borg backups for this host";

    repo = mkOption {
      type = types.str;
      default = null;
      example = "deadbeef@deadbeef.repo.borgbase.com:repo";
      description = "Borgbase repo info. Required.";
    };

    prune = mkOption {
      type = types.attrs;
      default = {
        keep = {
          daily = 7;
          weekly = 4;
          monthly = 6;
        };
      };
      description = "pruning options for borg";
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

        # temporary files created by cargo and `go build`
        "**/target"
        "/home/*/go/bin"
        "/home/*/go/pkg"
      ];
      description = "Paths to exclude from backup";
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs."borgbase" = {
      paths = cfg.paths;
      exclude = cfg.exclude;
      repo = cfg.repo;
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /root/borgbackup/passphrase";
      };
      environment.BORG_RSH = "ssh -i /root/borgbackup/ssh_key";
      extraCreateArgs = "--stats --list";
      extraPruneArgs = "--stats --list --save-space";
      doInit = true;
      compression = "auto,zstd";
      startAt = "daily";
      prune = cfg.prune;
    };
  };
}
