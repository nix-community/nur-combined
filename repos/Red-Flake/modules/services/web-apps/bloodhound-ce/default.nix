{
  config,
  pkgs,
  lib,
  utils,
  ...
}:
let
  cfg = config.services.bloodhound-ce;
  json = pkgs.formats.json { };

  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    ;

  # Compose host:port unless host already includes a colon (e.g. "host:port" or a path-like socket)
  mkAddr = host: port: if lib.hasInfix ":" host then host else "${host}:${toString port}";

in
{
  ###### options ###############################################################
  options.services.bloodhound-ce = {
    enable = mkEnableOption "BloodHound Community Edition API";

    package = mkPackageOption pkgs "bloodhound-ce" { };

    user = mkOption {
      type = types.str;
      default = "bloodhound";
      description = "User account under which BloodHound CE runs.";
    };

    group = mkOption {
      type = types.str;
      default = "bloodhound";
      description = "Group under which BloodHound CE runs.";
    };

    openFirewall = mkEnableOption "opening firewall ports for BloodHound CE";

    # Minimal server config written to /etc/bhapi/bhapi.json
    settings = mkOption {
      type = types.submodule {
        freeformType = json.type;
        options = {
          server = {
            host = mkOption {
              type = types.str;
              default = "0.0.0.0";
              description = "Address to bind the API server to.";
            };
            port = mkOption {
              type = types.port;
              default = 9090;
              description = "Port for the API server.";
            };
          };
          logLevel = mkOption {
            type = types.str;
            default = "info";
            description = "Log level (info, debug, warn, error).";
          };
          logPath = mkOption {
            type = types.str;
            default = "";
            description = "Optional path to a log file (empty = stdout only).";
          };
          recreateDefaultAdmin = mkOption {
            type = types.bool;
            default = false;
            description = "If true, BloodHound will recreate the default admin user on startup.";
          };
          defaultAdmin = mkOption {
            type = types.submodule {
              options = {
                principalName = mkOption {
                  type = types.str;
                  default = "admin";
                  description = "Default admin principal/user name.";
                };
                # Prefer passwordFile; 'password' will be embedded if you use it (not recommended).
                password = mkOption {
                  type = types.str;
                  default = "";
                  description = "Default admin password (discouraged: ends up in Nix store). Prefer passwordFile.";
                };
                passwordFile = mkOption {
                  type = types.path;
                  default = "";
                  example = "/run/secrets/bh-admin.pass";
                  description = "File containing the default admin password (recommended).";
                };
              };
            };
            default = { };
            description = "Default admin configuration.";
          };
        };
      };
      default = { };
      description = "BloodHound CE server configuration (subset).";
    };

    # PostgreSQL (API DB)
    database = {
      host = mkOption {
        type = types.str;
        default = "/run/postgresql";
        description = "PostgreSQL host (socket dir or hostname).";
      };
      port = mkOption {
        type = types.str;
        default = "5432";
        description = "PostgreSQL port.";
      };
      name = mkOption {
        type = types.str;
        default = "bloodhound";
        description = "PostgreSQL database name.";
      };
      user = mkOption {
        type = types.str;
        default = "bloodhound";
        description = "PostgreSQL user.";
      };
      password = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "s3cr3t";
        description = "PostgreSQL password (use passwordFile for secrets if possible).";
      };
      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/run/secrets/bh-db.env"; # contains: PGPASSWORD=...
        description = "Environment file with PGPASSWORD=... (preferred over `password`).";
      };
    };

    # Neo4j (graph DB)
    neo4j = {
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Neo4j host (or host:port).";
      };
      port = mkOption {
        type = types.port;
        default = 7687;
        description = "Neo4j Bolt port.";
      };
      database = mkOption {
        type = types.str;
        default = "neo4j";
        description = "Neo4j database name.";
      };
      user = mkOption {
        type = types.str;
        default = "neo4j";
        description = "Neo4j username.";
      };
      password = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "supersecret";
        description = "Neo4j password (prefer passwordFile for secrets).";
      };
      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/run/secrets/bh-neo4j.env"; # contains: bhe_neo4j_secret=...
        description = "Environment file with bhe_neo4j_secret=... (preferred).";
      };
    };

    # Which graph driver to use (BloodHound supports neo4j; keep default)
    # We need to use the Neo4j LTS version 4.4.x because In Neo4j 5.x the legacy procedure CALL db.indexes() was removed (replaced by SHOW INDEXES). BloodHound CE 8 still calls db.indexes, so it expects Neo4j 4.4.x.
    # See: https://github.com/SpecterOps/BloodHound/blob/03454913830fec12eebc4451dca8af8b3b3c44d7/tools/docker-compose/neo4j.Dockerfile#L17
    graphDriver = mkOption {
      type = types.enum [ "neo4j" ];
      default = "neo4j";
      description = "Graph driver to use.";
    };
  };

  ###### implementation ########################################################
  config = lib.mkMerge [

    (lib.mkIf cfg.enable {
      # Write upstream-style JSON config where BloodHound expects it
      environment.etc."bloodhound/bloodhound.config.json".source =
        json.generate "bloodhound.config.json"
          {
            version = 2;
            bind_addr = "${cfg.settings.server.host}:${toString cfg.settings.server.port}";
            work_dir = "/var/lib/bloodhound-ce/work";
            log_level = cfg.settings.logLevel; # "info" is fine; upstream examples use "INFO"
            log_path = cfg.settings.logPath;
            collectors_base_path = "${cfg.package}/share/bloodhound/collectors";

            # Set default admin credentials
            default_admin = {
              principal_name = cfg.settings.defaultAdmin.principalName;
              password = cfg.settings.defaultAdmin.password;
            };

            # Re-create default admin user on startup
            recreate_default_admin = cfg.settings.recreateDefaultAdmin;

            # --- PostgreSQL (the API DB) ---
            database = {
              addr = mkAddr cfg.database.host cfg.database.port; # "/run/postgresql" or "127.0.0.1:5432"
              database = cfg.database.name; # "bloodhound"
              username = cfg.database.user; # "bloodhound"
              # password via env: bhe_database_secret
            };

            # --- Neo4J (the Graph DB) ---
            graph_driver = cfg.graphDriver;
            neo4j = {
              addr = mkAddr cfg.neo4j.host cfg.neo4j.port;
              database = cfg.neo4j.database;
              username = cfg.neo4j.user;
              # password via env: bhe_neo4j_secret
            };
          };

      systemd.services.bloodhound-ce = {
        description = "BloodHound Community Edition API";
        wantedBy = [ "multi-user.target" ];

        # if you rely on a local postgres, leave postgresql.service here
        after = [
          "network-online.target"
        ]
        ++ lib.optionals (config.services.postgresql.enable or false) [ "postgresql.service" ]
        ++ lib.optionals (config.services.neo4j.enable or false) [ "neo4j.service" ];

        wants = [
          "network-online.target"
        ]
        ++ lib.optionals (config.services.postgresql.enable or false) [ "postgresql.service" ]
        ++ lib.optionals (config.services.neo4j.enable or false) [ "neo4j.service" ];

        serviceConfig = lib.mkMerge (
          let
            envFiles =
              lib.optional (cfg.database.passwordFile != null) cfg.database.passwordFile
              ++ lib.optional (cfg.neo4j.passwordFile != null) cfg.neo4j.passwordFile;
          in
          [
            {
              User = cfg.user;
              Group = cfg.group;

              # Creates /var/lib/bloodhound-ce and ensures ownership
              StateDirectory = [
                "bloodhound-ce"
                "bloodhound-ce/work"
              ];
              StateDirectoryMode = "0700";
              WorkingDirectory = "/var/lib/bloodhound-ce";

              ExecStart =
                let
                  args = [
                    (lib.getExe cfg.package)
                    "-configfile"
                    "/etc/bloodhound/bloodhound.config.json"
                  ];
                in
                utils.escapeSystemdExecArgs args;

              Environment = [
                "bhe_work_dir=/var/lib/bloodhound-ce/work"
                "bhe_collectors_base_path=${cfg.package}/share/bloodhound/collectors"
              ]
              # supply the DB secrets as env the app understands:
              ++ lib.optional (cfg.database.password != null) "bhe_database_secret=${cfg.database.password}"
              ++ lib.optional (cfg.neo4j.password != null) "bhe_neo4j_secret=${cfg.neo4j.password}";

              # reasonable default hardening settings
              NoNewPrivileges = true;
              PrivateDevices = true;
              ProtectKernelTunables = true;
              ProtectKernelModules = true;
              ProtectControlGroups = true;
              MemoryDenyWriteExecute = true;
              LockPersonality = true;
              RestrictAddressFamilies = [
                "AF_UNIX"
                "AF_INET"
                "AF_INET6"
              ];
              DevicePolicy = "closed";
              RestrictNamespaces = true;
              RestrictRealtime = true;
              RestrictSUIDSGID = true;

              # keep logs/private files private by default
              UMask = "0077";

              # nice-to-have
              Restart = "on-failure";
              RestartSec = "5s";
            }

            # Conditionally add EnvironmentFile when provided
            (mkIf (envFiles != [ ]) {
              # Allow providing one or more EnvironmentFile(s)
              EnvironmentFile = envFiles;
            })
          ]
        );
      };

      # System user/group (only if using defaults)
      users.users = mkIf (cfg.user == "bloodhound") {
        bloodhound = {
          isSystemUser = true;
          group = cfg.group;
        };
      };
      users.groups = mkIf (cfg.group == "bloodhound") {
        bloodhound = { };
      };

      # Open firewall if requested
      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.server.port ];
    })
  ];

  meta.maintainers = with lib.maintainers; [ Mag1cByt3s ];
}
