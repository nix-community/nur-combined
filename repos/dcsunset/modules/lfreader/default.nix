{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.lfreader;
in {
  options.services.lfreader = {
    enable = mkEnableOption "LFReader server";

    package = mkOption {
      type = types.package;
      description = "Package to use for lfreader (e.g. package from nur)";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen at";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host address to bind on";
    };

    dbPath = mkOption {
      type = types.str;
      default = "/var/lib/lfreader/db.sqlite";
      description = "Path of db file";
    };

    archivePath = mkOption {
      type = types.str;
      default = "/var/lib/lfreader/archives";
      description = "Path of archive dir";
    };

    userAgent = mkOption {
      type = types.str;
      default = "";
      description = "User agent to use when fetching resources (empty means no user agent)";
    };

    timeout = mkOption {
      type = types.int;
      default = 10;
      description = "User agent to use when fetching resources";
    };

    logLevel = mkOption {
      type = types.enum [ "notset" "debug" "info" "warning" "error" "critical" ];
      default = "info";
      description = "Log level";
    };

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "User to run the systemd service (`null` means root user)";
    };

    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional command-line arguments to pass to lfreader-server";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.lfreader = {
      description = "LFReader server";
      wantedBy = [ "multi-user.target" ];
      environment = {
        LFREADER_DB = cfg.dbPath;
        LFREADER_ARCHIVE = cfg.archivePath;
        LFREADER_USER_AGENT = cfg.userAgent;
        LFREADER_TIMEOUT = toString cfg.timeout;
        LFREADER_LOG_LEVEL = cfg.logLevel;
      };
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/lfreader-server --host ${cfg.host} --port ${toString cfg.port} \
            ${concatStringsSep " " cfg.extraOptions}
        '';
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictSUIDSGID = true;
      } // (optionalAttrs (cfg.user != null) {
        User = cfg.user;
      });
    };
  };
}
