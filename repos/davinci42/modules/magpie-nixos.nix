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
  isSystemUser = cfg.user == "magpie";
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
      default = if isSystemUser then "magpie" else config.users.users.${cfg.user}.group or "users";
      defaultText = lib.literalExpression ''if config.services.magpie.user == "magpie" then "magpie" else config.users.users.''${config.services.magpie.user}.group'';
      description = "Group under which Magpie runs.";
    };

    stateDir = lib.mkOption {
      type = lib.types.strMatching "/.*";
      default =
        if isSystemUser then
          "/var/lib/magpie"
        else
          config.users.users.${cfg.user}.home or "/home/${cfg.user}";
      defaultText = lib.literalExpression ''if config.services.magpie.user == "magpie" then "/var/lib/magpie" else config.users.users.''${config.services.magpie.user}.home'';
      description = "State directory holding Magpie configuration, credentials and caches.";
    };
  };

  config = lib.mkIf cfg.enable {
    inherit (shared) assertions;

    environment.systemPackages = [ cfg.package ];

    users.users = lib.mkIf isSystemUser {
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
        { HOME = cfg.stateDir; }
        cfg.environment
      ];
      preStart = shared.configureCmd;
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
      // lib.optionalAttrs (isSystemUser && cfg.stateDir == "/var/lib/magpie") {
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
