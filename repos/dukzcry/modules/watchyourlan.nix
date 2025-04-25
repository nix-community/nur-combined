{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.watchyourlan;
  format = pkgs.formats.json { };
in {
  options.services.watchyourlan = {
    enable = mkEnableOption "WatchYourLan";
    settings = mkOption {
      type = types.attrs;
      default = {};
    };
    user = mkOption {
      type = types.str;
      default = "watchyourlan";
    };
    group = mkOption {
      type = types.str;
      default = "watchyourlan";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/watchyourlan";
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "watchyourlan") {
      watchyourlan = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
        createHome = true;
      };
    };
    users.groups = mkIf (cfg.group == "watchyourlan") {
      watchyourlan = {};
    };
    systemd.services.watchyourlan = {
      after = [ "network.target" ];
      environment = cfg.settings;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${getExe pkgs.watchyourlan} -d ${cfg.dataDir}";
        Restart = "on-failure";
        TimeoutSec = 300;
        StartLimitBurst = 10;
        AmbientCapabilities = [ "CAP_NET_RAW" ];
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
