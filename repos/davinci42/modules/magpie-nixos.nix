{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.magpie;
  common = import ./magpie-common.nix { inherit lib pkgs; };
  shared = common.helpers cfg;
in
{
  options.services.magpie = common.commonOptions // {
    openFirewall = lib.mkEnableOption "opening the Magpie gateway (and Web UI when enabled) ports in the firewall";

    user = lib.mkOption {
      type = lib.types.str;
      default = "magpie";
      description = "User account under which Magpie runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "magpie";
      description = "Group under which Magpie runs.";
    };

    stateDir = lib.mkOption {
      type = lib.types.strMatching "/.*";
      default = "/var/lib/magpie";
      description = "State directory holding Magpie configuration, credentials and caches.";
    };
  };

  config = lib.mkIf cfg.enable {
    inherit (shared) assertions;

    environment.systemPackages = [ cfg.package ];

    users.users = lib.mkIf (cfg.user == "magpie") {
      magpie = {
        isSystemUser = true;
        inherit (cfg) group;
        home = cfg.stateDir;
      };
    };

    users.groups = lib.mkIf (cfg.group == "magpie") {
      magpie = { };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall (
      [ cfg.port ] ++ lib.optional cfg.web.enable cfg.web.port
    );

    systemd.services.magpie = {
      description = "Magpie local AI gateway";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = lib.mkMerge [
        shared.baseEnvironment
        {
          HOME = "${cfg.stateDir}/home";
          XDG_CONFIG_HOME = cfg.stateDir;
          XDG_CACHE_HOME = "${cfg.stateDir}/cache";
          XDG_DATA_HOME = "${cfg.stateDir}/data";
          XDG_STATE_HOME = "${cfg.stateDir}/state";
        }
        cfg.environment
      ];
      preStart = ''
        install -d -m 0700 "${cfg.stateDir}/home" "${cfg.stateDir}/magpie" "${cfg.stateDir}/cache" "${cfg.stateDir}/data" "${cfg.stateDir}/state"
        ${shared.configureCmd "${cfg.stateDir}/magpie"}
      '';
      serviceConfig = {
        ExecStart =
          if cfg.web.keyFile == null then
            lib.escapeShellArgs ([ (lib.getExe' cfg.package "magpie") ] ++ shared.serveArgs)
          else
            "${pkgs.writeShellScript "magpie-with-web-key" ''
              set -euo pipefail
              export MAGPIE_WEB_KEY="$(< "$CREDENTIALS_DIRECTORY/web-key")"
              exec ${lib.escapeShellArgs ([ (lib.getExe' cfg.package "magpie") ] ++ shared.serveArgs)}
            ''}";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.stateDir;
        Restart = "on-failure";
        RestartSec = 5;
        UMask = "0077";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.stateDir ];
      }
      // lib.optionalAttrs (cfg.user == "magpie" && cfg.stateDir == "/var/lib/magpie") {
        StateDirectory = "magpie";
        StateDirectoryMode = "0750";
      }
      // lib.optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      }
      // lib.optionalAttrs (cfg.web.keyFile != null) {
        LoadCredential = [ "web-key:${cfg.web.keyFile}" ];
      };
    };
  };
}
