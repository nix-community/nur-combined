{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.btrbk;
  configFile = pkgs.writeText "btrbk.conf" ''
    volume ${cfg.volume}
    ${cfg.config}
  '';
in {

  options = {
    services.btrbk = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to start the btrbk snapshotting service.";
      };
 
      volume = mkOption {
        type = types.str;
        default = "";
        description = "The volume to mount";
      };

      config = mkOption {
        type = types.lines;
        default = "";
        description = "The literal contents of `btrbk.conf` except for the `volume`.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.btrbk = {
      description = "Takes BTRFS snapshots and maintains retention policies.";
      script = ''
        ${pkgs.coreutils}/bin/mkdir -p ${cfg.volume}
        ${pkgs.utillinux}/bin/mount -L NIXOS ${cfg.volume}
        ${pkgs.btrbk}/bin/btrbk -c ${configFile} run
        ${pkgs.utillinux}/bin/umount ${cfg.volume}
      '';
    };

    systemd.timers.btrbk = {
      description = "Timer to take BTRFS snapshots and maintain retention policies.";
      wantedBy = [ "timers.target" ];
      timerConfig = {
	OnBootSec="30m";
        OnUnitActiveSec="30m";
      };
    };
  };
}
