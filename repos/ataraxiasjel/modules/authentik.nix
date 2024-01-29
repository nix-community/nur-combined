{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.authentik;
  databaseActuallyCreateLocally =
    cfg.database.createLocally && cfg.database.host == "/run/postgresql";

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    mdDoc
    literalExpression
    optional
    attrsets
    ;
  inherit (attrsets) optionalAttrs;
  inherit (types)
    str
    bool
    port
    submodule
    package
    nullOr
    path
    enum
    ;

  hostWithPort = h: p: "${h}:${toString p}";

  authentikBaseService = {
    after = [ "network.target" ] ++ optional databaseActuallyCreateLocally "postgresql.service";
    wantedBy = [ "multi-user.target" ];
    path = [ cfg.package ];
    environment =
      let
        listenAddress = hostWithPort cfg.listen.address;
      in
      {
        AUTHENTIK_REDIS__HOST = cfg.redis.host;
        AUTHENTIK_REDIS__PORT = toString cfg.redis.port;

        AUTHENTIK_POSTGRESQL__HOST = cfg.database.host;
        AUTHENTIK_POSTGRESQL__PORT = mkIf (cfg.database.port != null) "${toString cfg.database.port}";
        AUTHENTIK_POSTGRESQL__USER = cfg.database.user;
        AUTHENTIK_POSTGRESQL__NAME = cfg.database.name;

        AUTHENTIK_LISTEN__HTTP = listenAddress cfg.listen.http;
        AUTHENTIK_LISTEN__HTTPS = listenAddress cfg.listen.https;

        # initial password for admin user
        AUTHENTIK_BOOTSTRAP_PASSWORD = cfg.defaultPassword;

        # disable outbound connections
        AUTHENTIK_DISABLE_UPDATE_CHECK = "true";
        AUTHENTIK_ERROR_REPORTING__ENABLED = "false";
        AUTHENTIK_DISABLE_STARTUP_ANALYTICS = "true";
        AUTHENTIK_AVATARS = "initials";

        AUTHENTIK_LOG_LEVEL = cfg.logLevel;
      };
    serviceConfig = {
      User = "authentik";
      Group = "authentik";
      EnvironmentFile = cfg.environmentFile;
      WorkingDirectory = cfg.package;
      DynamicUser = true;
      RuntimeDirectory = "authentik";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      SystemCallFilter = "~@cpu-emulation @keyring @module @obsolete @raw-io @reboot @swap @sync";
      ConfigurationDirectory = "authentik";
      StateDirectoryMode = "0750";
    };
  };
in
{
  options.services.authentik = {
    enable = mkEnableOption "Enables Authentik service";

    package = mkOption {
      type = package;
      default = pkgs.authentik;
      defaultText = literalExpression "pkgs.authentik";
      description = mdDoc "Authentik package to use.";
    };

    defaultPassword = mkOption {
      description = mdDoc "Default admin password. Only read on first startup.";
      type = str;
      default = "change-me";
    };

    logLevel = mkOption {
      description = mdDoc ''
        Log level for the server and worker containers.
        Setting the log level to trace will include sensitive details in logs, so it shouldn't be used in most cases.
      '';
      type = enum [
        "trace"
        "debug"
        "info"
        "warning"
        "error"
      ];
      default = "info";
    };

    listen = mkOption {
      description = mdDoc "Listen ports";
      default = { };
      type = submodule {
        options = {
          http = mkOption {
            description = mdDoc "HTTP port.";
            type = port;
            default = 9000;
          };
          https = mkOption {
            description = mdDoc "HTTPS port.";
            type = port;
            default = 9443;
          };
          address = mkOption {
            description = mdDoc "Address to listen on.";
            type = str;
            default = "0.0.0.0";
          };
        };
      };
    };
    redis = {
      createLocally = mkOption {
        description = mdDoc "Configure local Redis server for Authentik.";
        type = bool;
        default = true;
      };

      host = mkOption {
        description = mdDoc "Redis host.";
        type = str;
        default = "127.0.0.1";
      };

      port = mkOption {
        description = mdDoc "Redis port.";
        type = port;
        default = 31637;
      };
    };
    ssl = {
      cert = mkOption {
        type = nullOr path;
        default = null;
      };

      key = mkOption {
        type = nullOr path;
        default = null;
      };

      name = mkOption {
        type = str;
        default = "SSL from NIXOS";
      };
    };

    environmentFile = mkOption {
      type = nullOr path;
      default = null;
      example = "/var/lib/authentik/secrets/db-password";
      description = mdDoc ''
        File in the format of an EnvironmentFile as described by systemd.exec(5).
      '';
    };

    database = {
      createLocally = mkOption {
        description = mdDoc "Configure local PostgreSQL database server for authentik.";
        type = bool;
        default = true;
      };

      host = mkOption {
        type = str;
        default = "/run/postgresql";
        example = "192.168.23.42";
        description = mdDoc "Database host address or unix socket.";
      };

      port = mkOption {
        type = nullOr port;
        default = if cfg.database.createLocally then null else 5432;
        defaultText = literalExpression ''
          if config.database.createLocally then null else 5432
        '';
        description = mdDoc "Database host port.";
      };

      name = mkOption {
        type = str;
        default = "authentik";
        description = mdDoc "Database name.";
      };

      user = mkOption {
        type = str;
        default = "authentik";
        description = mdDoc "Database user.";
      };
    };

    outposts = mkOption {
      type = submodule {
        options = {
          ldap = mkOption {
            type = submodule {
              options = {
                enable = mkEnableOption (lib.mdDoc "the authentik ldap outpost");
                package = mkOption {
                  type = path;
                  default = pkgs.authentik-outposts.ldap;
                };
                host = mkOption {
                  type = str;
                  default =
                    if cfg.outposts.ldap.insecure then
                      "http://127.0.0.1:${toString cfg.listen.http}"
                    else
                      "https://127.0.0.1:${toString cfg.listen.https}";
                };
                insecure = mkOption {
                  type = bool;
                  default = false;
                };
                environmentFile = mkOption {
                  type = nullOr path;
                  default = null;
                  example = "/var/lib/authentik-ldap/secrets/env";
                  description = mdDoc ''
                    File in the format of an EnvironmentFile as described by systemd.exec(5).
                  '';
                };
                listen = mkOption {
                  description = mdDoc "Listen ports";
                  default = { };
                  type = submodule {
                    options = {
                      ldap = mkOption {
                        description = mdDoc "LDAP port.";
                        type = port;
                        default = 3389;
                      };
                      ldaps = mkOption {
                        description = mdDoc "LDAPS port.";
                        type = port;
                        default = 6636;
                      };
                      address = mkOption {
                        description = mdDoc "Address to listen on.";
                        type = str;
                        default = "0.0.0.0";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
      default = {
        ldap = {
          enable = false;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.authentik = {
      isSystemUser = true;
      home = cfg.package;
      group = "authentik";
    };
    users.groups.authentik = { };

    services.postgresql = mkIf databaseActuallyCreateLocally {
      enable = true;
      ensureUsers = [
        {
          name = cfg.database.name;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ cfg.database.name ];
    };

    services.redis.servers.authentik = mkIf (cfg.redis.createLocally && cfg.redis.host == "127.0.0.1") {
      enable = true;
      port = cfg.redis.port;
      bind = "127.0.0.1";
    };

    systemd.services.authentik-server = authentikBaseService // {
      serviceConfig = authentikBaseService.serviceConfig // {
        ExecStart = "${cfg.package}/bin/ak server";
      };
    };

    systemd.services.authentik-worker = authentikBaseService // {
      serviceConfig = authentikBaseService.serviceConfig // {
        ExecStart = "${cfg.package}/bin/ak worker";
      };
    };

    systemd.services.authentik-ssl-import =
      mkIf (cfg.ssl.cert != null && cfg.ssl.key != null) authentikBaseService
      // {
        before = [ "authentik-server.service" ];
        serviceConfig = authentikBaseService.serviceConfig // {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = ''${cfg.package}/bin/ak import_certificate --name "${cfg.ssl.name}" --certificate "${cfg.ssl.cert}" --private-key "${cfg.ssl.key}"'';
        };
      };

    systemd.services.authentik-ldap-outpost =
      let
        ldapCfg = cfg.outposts.ldap;
      in
      mkIf ldapCfg.enable (
        authentikBaseService
        // {
          description = "authentik ldap outpost";
          environment =
            let
              listenAddress = hostWithPort ldapCfg.listen.address;
            in
            {
              AUTHENTIK_HOST = ldapCfg.host;
              AUTHENTIK_LISTEN__LDAP = listenAddress ldapCfg.listen.ldap;
              AUTHENTIK_LISTEN__LDAPS = listenAddress ldapCfg.listen.ldaps;
            }
            // optionalAttrs ldapCfg.insecure { AUTHENTIK_INSECURE = "true"; };
          serviceConfig = authentikBaseService.serviceConfig // {
            ExecStart = "${cfg.outposts.ldap.package}/bin/ldap";
            EnvironmentFile = ldapCfg.environmentFile;
          };
        }
      );
  };
}
