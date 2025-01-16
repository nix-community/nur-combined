{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.metube;
  format = pkgs.formats.json { };
in {
  options.services.metube = {
    enable = mkEnableOption "MeTube";
    settings = mkOption {
      type = types.attrs;
      default = {};
    };
    ytdlSettings = mkOption {
      type = format.type;
      default = {};
    };
    user = mkOption {
      type = types.str;
      default = "metube";
    };
    group = mkOption {
      type = types.str;
      default = "metube";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/metube";
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "metube") {
      metube = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
        createHome = true;
      };
    };
    users.groups = mkIf (cfg.group == "metube") {
      metube = {};
    };
    systemd.services.metube = {
      after = [ "network.target" ];
      environment = cfg.settings // {
        STATE_DIR = cfg.dataDir;
      } // optionalAttrs (cfg.ytdlSettings != {}) {
        YTDL_OPTIONS = builtins.toJSON cfg.ytdlSettings;
      };
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = getExe pkgs.nur.repos.dukzcry.metube;
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
