{ config, pkgs, lib, ... }:

with lib;

let
  dataDir = "/var/lib/matrix-registration";
  cfg = config.services.matrix-registration;
  format = pkgs.formats.yaml { };
  matrix-registration-config =
    format.generate "matrix-registration-config.yaml" cfg.settings;
  matrix-registration-cli-wrapper = pkgs.stdenv.mkDerivation {
    name = "matrix-registration-cli-wrapper";
    buildInputs = [ pkgs.makeWrapper ];
    buildCommand = ''
      mkdir -p $out/bin
      makeWrapper ${pkgs.matrix-registration}/bin/matrix-registration "$out/bin/matrix-registration" \
        --add-flags "--config-path='${matrix-registration-config}'"
    '';
  };

in {
  options.services.matrix-registration = {
    enable = lib.mkEnableOption "Start Matrix Registration";

    settings = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        freeformType = format.type;

        options = {
          server_location = lib.mkOption {
            type = lib.types.str;
            description = "The client baseurl";
            example = "https://matrix.org";
          };
          server_name = lib.mkOption {
            type = lib.types.str;
            description = "The server_name";
            example = "matrix.org";
            default = optionalString config.services.matrix-synapse.enable
              config.services.matrix-synapse.server_name;
          };
          shared_secret = lib.mkOption {
            type = lib.types.str;
            description = "The shared secret with the synapse configuration";
            example = "RegistrationSharedSecret";
            default = optionalString config.services.matrix-synapse.enable
              config.services.matrix-synapse.registration_shared_secret;
          };
          admin_secret = lib.mkOption {
            type = lib.types.str;
            description = "The admin secret to access the API";
            example = "APIAdminPassword";
          };
          base_url = lib.mkOption {
            type = lib.types.str;
            description = "A prefix for all endpoints";
            default = "";
          };
          riot_instance = lib.mkOption {
            type = lib.types.str;
            description = "The element instaince to redirect to";
            default = "https://app.element.io/";
          };
          db = lib.mkOption {
            type = lib.types.str;
            default = "sqlite:///${dataDir}/db.sqlite3";
            description = "Where to store the database";
          };
          host = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            description = "What host to listen on";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 5000;
          };
          rate_limit = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "100 per day" "10 per minute" ];
          };
          allow_cors = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          ip_logging = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Save IPs in the database";
          };
          logging = lib.mkOption {
            type = lib.types.attrs;
            default = {
              disable_existing_loggers = false;
              version = 1;
              root = {
                level = "DEBUG";
                handlers = [ "console" "file" ];
              };
              formatters = {
                brief = { format = "%(name)s - %(levelname)s - %(message)s"; };
                precise = {
                  format =
                    "%(asctime)s - %(name)s - %(levelname)s - %(message)s";
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
          password.min_length = lib.mkOption {
            type = lib.types.ints.positive;
            default = 8;
            description = "Minimum password length for the registered user";
          };
        };
      };
    };

    serviceDependencies = mkOption {
      type = with types; listOf str;
      default =
        optional config.services.matrix-synapse.enable "matrix-synapse.service";
      description = ''
        List of Systemd services to require and wait for when starting the application service.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.matrix-registration = {
      description =
        "matrix-registration, a token based matrix registration api.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;

      preStart = ''
        # run automatic database init and migration scripts
        ${pkgs.matrix-registration.alembic}/bin/alembic -x dbname='${matrix-registration-config}' upgrade head
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
        WorkingDirectory =
          pkgs.matrix-registration; # necessary for the database migration scripts to be found
        StateDirectory = baseNameOf dataDir;
        UMask = 27;

        ExecStart = ''
          ${pkgs.matrix-registration}/bin/matrix-registration \
              --config-path='${matrix-registration-config}' serve
        '';
      };
    };

    environment.systemPackages = [ matrix-registration-cli-wrapper ];
  };

  # meta.maintainers = with maintainers; [ zeratax ];
}
