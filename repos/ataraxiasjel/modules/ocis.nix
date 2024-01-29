{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.ocis;
  format = pkgs.formats.yaml { };

  linkConfigs = confDir: lib.pipe cfg.settings [
    (lib.attrsets.mapAttrs (n: v: format.generate "${n}.yaml" v))
    (lib.mapAttrsToList (n: v: "ln -sf ${v} ${confDir}/${n}.yaml"))
    (lib.concatStringsSep "\n")
  ];

  mkExport = { arg, value }: "export ${arg}=${value}";
  adminpass = {
    arg = "ADMIN_PASSWORD";
    value = ''"$(<"${toString cfg.adminpassFile}")"'';
  };
in
{
  options.services.ocis = {
    enable = mkEnableOption (lib.mdDoc "ownCloud Infinite Scale Stack");
    package = mkOption {
      type = types.package;
      description = lib.mdDoc "Which package to use for the ocis instance.";
      default = pkgs.ocis-bin;
    };
    configDir = mkOption {
      default = "/var/lib/ocis/.config";
      type = types.path;
      description = lib.mdDoc "The config directory. Set OCIS_CONFIG_DIR env variable.";
    };
    baseDataPath = mkOption {
      default = "/var/lib/ocis";
      type = types.path;
      description = lib.mdDoc "The base data directory. Set OCIS_BASE_DATA_PATH env variable.";
    };
    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = lib.literalExpression ''
        {
          OCIS_URL = "https://localhost:9200";
        }
      '';
      description = lib.mdDoc "Environment variables to pass to ocis instance.";
    };
    environmentFile = mkOption {
      type = with types; nullOr str;
      default = null;
      description = lib.mdDoc ''
        file in the format of an EnvironmentFile as described by systemd.exec(5).
      '';
    };
    adminpassFile = mkOption {
      type = with types; nullOr str;
      default = null;
      description = lib.mdDoc ''
        The full path to a file that contains the admin's password. Must be
        readable by user `ocis`. The password is set only in the initial
        setup of Ocis by the systemd service `ocis-init.service`.
      '';
    };
    settings = mkOption {
      type = with types; attrsOf format.type;
      default = { };
      example = lib.literalExpression ''
        {
          auth-bearer = {
            tracing = {
              enabled = true;
            };
          };
          proxy = {
            user_oidc_claim = "preferred_username";
            user_cs3_claim = "username";
          };
        }
      '';
      description = lib.mdDoc ''
        OCIS configuration. Refer to
        <https://doc.owncloud.com/ocis/next/deployment/services/services.html>
        for details on supported values.
      '';
    };
  };
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.configDir}' - ocis ocis - -"
      "d '${cfg.baseDataPath}' - ocis ocis - -"
    ];
    systemd.services.ocis-init = rec {
      before = [ "ocis-server.service" ];
      requiredBy = [ "ocis-server.service" ];
      path = [ cfg.package ];
      environment = {
        OCIS_CONFIG_DIR = cfg.configDir;
        OCIS_BASE_DATA_PATH = cfg.baseDataPath;
      } // cfg.environment;
      script = ''
        ${lib.optionalString (cfg.settings != { }) "${linkConfigs environment.OCIS_CONFIG_DIR}"}
        if [ ! -f "$OCIS_CONFIG_DIR/ocis.yaml" ]; then
          ${
            lib.optionalString (cfg.adminpassFile != null) ''
              if [ ! -r "${cfg.adminpassFile}" ]; then
                echo "adminpassFile ${cfg.adminpassFile} is not readable by ocis:ocis! Aborting..."
                exit 1
              fi
              if [ -z "$(<${cfg.adminpassFile})" ]; then
                echo "adminpassFile ${cfg.adminpassFile} is empty!"
                exit 1
              fi
              ${mkExport adminpass}
            ''
          }
          ocis init
        fi
      '';
      serviceConfig = {
        Type = "simple";
        StateDirectory = "ocis";
        User = "ocis";
        Group = "ocis";
      } // optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };

    systemd.services.ocis-server = {
      description = "ownCloud Infinite Scale Stack";
      wantedBy = [ "multi-user.target" ];
      path = [ cfg.package ];
      environment = {
        OCIS_CONFIG_DIR = cfg.configDir;
        OCIS_BASE_DATA_PATH = cfg.baseDataPath;
        OCIS_URL = "https://localhost:9200";
        PROXY_HTTP_ADDR = "127.0.0.1:9200";
      } // cfg.environment;
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStart = "${cfg.package}/bin/ocis server";
        User = "ocis";
        Group = "ocis";
        LimitNOFILE = 65536;
      } // optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };

    environment.systemPackages = [ cfg.package ];

    users.groups.ocis = { };
    users.users.ocis = {
      description = "Ocis Daemon User";
      group = "ocis";
      isSystemUser = true;
    };
  };
}
