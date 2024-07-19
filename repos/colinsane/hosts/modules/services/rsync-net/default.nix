{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.rsync-net;
  sane-backup-rsync-net = pkgs.static-nix-shell.mkBash {
    pname = "sane-backup-rsync-net";
    pkgs = [
      "nettools"
      "openssh"
      "rsync"
      "sane-scripts.vpn"
      "sanebox"
    ];
    srcRoot = ./.;
  };
in
{
  options = with lib; {
    sane.services.rsync-net.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.services.rsync-net.dirs = mkOption {
      type = types.listOf types.str;
      description = ''
        list of directories to upload to rsync.net.
        note that this module does NOT add any encryption to the files (layer that yourself).
      '';
      default = [
        "/nix/persist/private"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.rsync-net = {
      description = "backup files to rsync.net";
      serviceConfig.ExecStart = "${lib.getExe sane-backup-rsync-net} ${lib.escapeShellArgs cfg.dirs}";
      serviceConfig.Type = "simple";
      serviceConfig.Restart = "no";
      serviceConfig.User = "colin";
      serviceConfig.Group = "users";
    };
    systemd.timers.rsync-net = {
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        # run 2x daily; at 11:00:00, 23:00:00
        OnCalendar = "11,23:00:00";
      };
    };
  };
}
