{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tokenrouter;
  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" cfg.settings;
  createAdmin =
    cfg.database.createLocally && cfg.initialEmail != null && cfg.initialHashedPasswordFile != null;
in
{
  options.services.tokenrouter = {
    enable = lib.mkEnableOption "TokenRouter";
    package = lib.mkPackageOption pkgs "tokenrouter" { };

    database.createLocally = lib.mkEnableOption "creating a local PostgreSQL server" // {
      default = true;
    };

    redis.createLocally = lib.mkEnableOption "creating a local Redis server" // {
      default = true;
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Environment file.";
    };

    initialEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Initial email for the admin account.";
    };

    initialHashedPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Initial password hash file (produced by `mkpasswd -m bcrypt`) for the admin account.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;
        options = {
          config_version = lib.mkOption {
            type = lib.types.enum [ 2 ];
            default = 2;
            description = "Version of the configuration.";
          };
          timezone = lib.mkOption {
            type = lib.types.str;
            default = lib.defaultTo "Etc/UTC" config.time.timeZone;
            description = "Time zone.";
          };
          log = {
            output = {
              to_file = lib.mkEnableOption "logging to file";
            };
          };
          server = {
            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "The address to listen on.";
            };
            port = lib.mkOption {
              type = lib.types.port;
              default = 8080;
              description = "The port to listen on.";
            };
          };
          database = {
            host = lib.mkOption {
              type = lib.types.str;
              default = "localhost";
              description = "Database host.";
            };
            user = lib.mkOption {
              type = lib.types.str;
              default = "tokenrouter";
              description = "Database user.";
            };
            dbname = lib.mkOption {
              type = lib.types.str;
              default = "tokenrouter";
              description = "Database name.";
            };
          };
          redis = {
            host = lib.mkOption {
              type = lib.types.str;
              default = "localhost";
              description = "Redis host.";
            };
          };
        };
      };
      default = { };
      description = ''
        Configuration, see <https://github.com/TokenFlux/TokenRouter/blob/main/deploy/config.example.yaml> for documentation.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tokenrouter.settings = {
      database.host = lib.mkIf cfg.database.createLocally "/run/postgresql";
      redis.host = lib.mkIf cfg.redis.createLocally config.services.redis.servers.tokenrouter.unixSocket;
    };

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ cfg.settings.database.dbname ];
      ensureUsers = [
        {
          name = cfg.settings.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    services.redis.servers.tokenrouter = lib.mkIf cfg.redis.createLocally {
      enable = true;
    };

    systemd.services.tokenrouter = {
      description = "TokenRouter LLM Gateway";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
      ]
      ++ lib.optional cfg.database.createLocally "postgresql.target"
      ++ lib.optional cfg.redis.createLocally "redis-tokenrouter.service";
      wants =
        lib.optional cfg.database.createLocally "postgresql.target"
        ++ lib.optional cfg.redis.createLocally "redis-tokenrouter.service";

      environment = {
        CONFIG_FILE = configFile;
        DATA_DIR = "/var/lib/tokenrouter";
      };

      postStart =
        let
          curl = lib.getExe pkgs.curl;
          psql = lib.getExe' config.services.postgresql.package "psql";
        in
        lib.mkIf createAdmin ''
          until ${curl} -s http://${cfg.settings.server.host}:${toString cfg.settings.server.port}/health >/dev/null; do sleep 1; done
          ${psql} -h ${cfg.settings.database.host} -d ${cfg.settings.database.dbname} \
            -v ON_ERROR_STOP=1 \
            -v email=${lib.escapeShellArg cfg.initialEmail} \
            -v hash="$(< "$CREDENTIALS_DIRECTORY/admin-password-hash")" \
          <<'EOF'
            INSERT INTO users (email, password_hash, role)
            SELECT :'email', :'hash', 'admin'
            WHERE NOT EXISTS (SELECT 1 FROM users);
          EOF
        '';

      serviceConfig = {
        User = "tokenrouter";
        Group = "tokenrouter";
        DynamicUser = true;

        SupplementaryGroups = lib.optional cfg.redis.createLocally "redis-tokenrouter";

        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

        StateDirectory = "tokenrouter";
        WorkingDirectory = "%S/tokenrouter";

        Restart = "always";

        LoadCredential = lib.mkIf createAdmin [
          "admin-password-hash:${cfg.initialHashedPasswordFile}"
        ];

        ExecStart = "${lib.getExe cfg.package}";
      };
    };
  };
}
