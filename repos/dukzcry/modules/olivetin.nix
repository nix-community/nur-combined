{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.olivetin;
  format = pkgs.formats.yaml { };
in {
  options.services.olivetin = {
    enable = mkEnableOption "OliveTin";
    settings = mkOption {
      type = format.type;
      default = {};
    };
    user = mkOption {
      type = types.str;
      default = "olivetin";
    };
    group = mkOption {
      type = types.str;
      default = "olivetin";
    };
    port = mkOption {
      type = types.port;
      default = 1337;
    };
    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "olivetin") {
      olivetin = {
        group = cfg.group;
        home = "/etc/OliveTin";
        isSystemUser = true;
        createHome = true;
      };
    };
    users.groups = mkIf (cfg.group == "olivetin") {
      olivetin = {};
    };
    environment.etc = optionalAttrs (cfg.settings != {}) {
      "OliveTin/config.yaml" = {
        text = generators.toYAML { } (cfg.settings // {
          listenAddressSingleHTTPFrontend = "${cfg.listenAddress}:${toString cfg.port}";
        });
        mode = "0440";
        user = cfg.user;
        group = cfg.group;
      };
    };
    systemd.services.olivetin = {
      after = [ "multi-user.target" ];
      path = with pkgs; with pkgs.nur.repos.dukzcry; [ bash olivetin openssh ];
      restartTriggers = [ config.environment.etc."OliveTin/config.yaml".source ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${getExe pkgs.nur.repos.dukzcry.olivetin} -configdir /etc/OliveTin";
        Restart = "always";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
