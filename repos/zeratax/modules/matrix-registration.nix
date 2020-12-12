{ config, pkgs, lib, ... }:

with lib;

let
  dataDir = "/var/lib/matrix-registration";
  cfg = config.services.matrix-registration;
  # TODO: switch to configGen.json once RFC42 is implemented
  settingsFile = pkgs.writeText "matrix-registration-settings.yaml" (builtins.toJSON cfg.settings);

in {
  options = {
    services.matrix-registration = {
      enable = mkEnableOption "matrix-registration, a token based matrix registration api";

      settings = mkOption rec {
        # TODO: switch to types.config.json as prescribed by RFC42 once it's implemented
        type = types.attrs;
        apply = recursiveUpdate default;
        default = {
          server_location = "";
          server_name = optionalString config.services.matrix-synapse.enable config.services.matrix-synapse.server_name;
          shared_secret = optionalString config.services.matrix-synapse.enable config.services.matrix-synapse.registration_shared_secret;
          admin_secret = "APIAdminPassword";
          base_url = "";
          riot_instance = "https://riot.home.server.de";
          db = "sqlite:///${dataDir}/db.sqlite3";
          host = "localhost";
          port = 5000;
          rate_limit = ["100 per day" "10 per minute"];
          allow_cors = false;
          password = {
            min_length = 8;
          };
          ip_logging = false;
          logging = {
            disable_existing_loggers = false;
            version = 1;
            root = {
              level = "DEBUG";
              handlers = ["console" "file"];
            };
            formatters = {
                brief = {
                  format = "%(name)s - %(levelname)s - %(message)s";
                };
                precise = {
                  format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s";
                };
            };
            handlers = {
              console = {
                class = "logging.StreamHandler";
                level = "INFO";
                formatter = "brief";
                stream = "ext://sys.stdout";
              };
              file = {
                 class = "logging.handlers.RotatingFileHandler";
                  formatter = "precise";
                  level = "INFO";
                  filename = "${dataDir}/m_reg.log";
                  maxBytes = 10485760;
                  backupCount = 3;
                  encoding = "utf8";
              };
            };
          };
        };
        example = literalExample ''
          {
            server_location = "https://matrix.org";
            server_name = "matrix.org";
            shared_secret = "registration_shared_secret";
          }
        '';
        description = ''
          <filename>config.yaml</filename> configuration as a Nix attribute set.
          Configuration options should match those described in
          <link xlink:href="https://github.com/ZerataX/matrix-registration/blob/master/config.sample.yaml">
          config.sample.yaml</link>.
        '';
      };

      serviceDependencies = mkOption {
        type = with types; listOf str;
        default = optional config.services.matrix-synapse.enable "matrix-synapse.service";
        description = ''
          List of Systemd services to require and wait for when starting the application service.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.matrix-registration = {
      description = "matrix-registration, a token based matrix registration api.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;

      preStart = ''
        # run automatic database init and migration scripts
        ${pkgs.matrix-registration.alembic}/bin/alembic -x dbname='${settingsFile}' upgrade head
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";

        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        DynamicUser = true;
        PrivateTmp = true;
        WorkingDirectory = pkgs.matrix-registration; # necessary for the database migration scripts to be found
        StateDirectory = baseNameOf dataDir;
        UMask = 0027;

        ExecStart = ''
          ${pkgs.matrix-registration}/bin/matrix-registration \
            --config-path='${settingsFile}' serve
        '';
      };
    };
  };

  # meta.maintainers = with maintainers; [ zeratax ];
}