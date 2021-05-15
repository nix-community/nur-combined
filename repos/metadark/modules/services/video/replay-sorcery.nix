{ config, lib, pkgs, ... }:

with lib;

let
  nur = import ../../.. { inherit pkgs; };
  cfg = config.services.replay-sorcery;
in
{
  options = {
    services.replay-sorcery = {
      enable = mkEnableOption "the ReplaySorcery service for instant-replays";

      enableSysAdminCapability = mkEnableOption ''
        the system admin capability to support hardware accelerated
        video capture. This is equivalent to running ReplaySorcery as
        root, so use with caution'';

      autoStart = mkOption {
        default = false;
        type = types.bool;
        description = "Automatically start ReplaySorcery when graphical-session.target starts";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ nur.replay-sorcery ];
    systemd.packages = [ nur.replay-sorcery ];

    security.wrappers = mkIf cfg.enableSysAdminCapability {
      replay-sorcery = {
        source = "${nur.replay-sorcery}/bin/replay-sorcery";
        capabilities = "cap_sys_admin+ep";
      };
    };

    systemd.user.services.replay-sorcery = {
      wantedBy = mkIf cfg.autoStart [ "graphical-session.target" ];
      partOf = mkIf cfg.autoStart [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = mkIf cfg.enableSysAdminCapability [
          "" # Tell systemd to clear the existing ExecStart list, to prevent appending to it.
          "${config.security.wrapperDir}/replay-sorcery"
        ];
      };
    };
  };

  meta = {
    maintainers = with maintainers; [ metadark ];
  };
}
