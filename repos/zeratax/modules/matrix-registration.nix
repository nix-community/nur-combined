{ config, pkgs, lib, ... }:

with lib;
let
  dataDir = "/var/lib/matrix-registration";
  cfg = config.services.matrix-registration;
  format = pkgs.formats.yaml { };
  matrix-registration-config =
    format.generate "config.yaml" cfg.settings;
  matrix-registration-cli-wrapper = pkgs.stdenv.mkDerivation {
    name = "matrix-registration-cli-wrapper";
    buildInputs = [ pkgs.makeWrapper ];
    buildCommand = ''
      mkdir -p $out/bin
      makeWrapper ${pkgs.matrix-registration}/bin/matrix-registration "$out/bin/matrix-registration" \
        --add-flags "--config-path='${matrix-registration-config}'"
    '';
  };

in
{
  options.services.matrix-registration = {
    enable = mkEnableOption "Start Matrix Registration";

    settings = mkOption {
      default = { };
      type = types.submodule {
        freeformType = format.type;

        options = {
          server_location = mkOption {
            type = types.str;
            description = "The client base URL";
            example = "https://matrix.example.tld";
          };
          server_name = mkOption {
            type = types.str;
            description = "The server_name";
            example = "example.tld";
            default = optionalString config.services.matrix-synapse.enable
              config.services.matrix-synapse.server_name;
          };
          registration_shared_secret = mkOption {
            type = types.str;
            description =
              "The registration shared secret with the synapse configuration";
            example = "RegistrationSharedSecret";
            default = optionalString config.services.matrix-synapse.enable
              config.services.matrix-synapse.registration_shared_secret;
          };
          admin_secret = mkOption {
            type = types.str;
            description = "The admin secret to access the API";
            example = "APIAdminPassword";
          };
          base_url = mkOption {
            type = types.str;
            description = "A prefix for all endpoints";
            default = "";
          };
          client_redirect = mkOption {
            type = types.str;
            description =
              "The client instance to redirect after succesful registration";
            default = "https://app.element.io/#/login";
          };
          client_logo = mkOption {
            type = types.path;
            description = "The client logo to display";
            default =
              "${pkgs.matrix-registration}/matrix_registration/static/images/element-logo.png";
          };
          db = mkOption {
            type = types.str;
            default = "sqlite:///${dataDir}/db.sqlite3";
            description = "Where to store the database";
          };
          host = mkOption {
            type = types.str;
            default = "localhost";
            description = "What host to listen on";
          };
          port = mkOption {
            type = types.port;
            default = 5000;
            description = "What port to listen on";
          };
          rate_limit = mkOption {
            type = types.listOf types.str;
            default = [ "100 per day" "10 per minute" ];
            description =
              "How often is one IP allowed to access matrix-registration";
          };
          allow_cors = mkOption {
            type = types.bool;
            default = false;
            description = "Allow Cross Origin Resource Sharing";
          };
          ip_logging = mkOption {
            type = types.bool;
            default = false;
            description = "Save IPs in the database";
          };
          logging = mkOption {
            type = types.attrs;
            description = ''
              Python logging config, see <link xlink:href="https://docs.python.org/3/library/logging.config.html#configuration-dictionary-schema>python docs</link>
            '';
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
                  filename = "${dataDir}/matrix-registration.log";
                  maxBytes = 10485760;
                  backupCount = 3;
                  encoding = "utf8";
                };
              };
            };
          };
          password.min_length = mkOption {
            type = types.ints.positive;
            default = 8;
            description = "Minimum password length for the registered user";
          };
        };
      };
    };

    credentialsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        File containing variables to be passed to the matrix-registration service,
        in which secret tokens can be specified securely by defining values for
        <literal>REGISTRATION_SHARED_SECRET</literal>,
        <literal>ADMIN_SECRET</literal>
      '';
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
        ${pkgs.matrix-registration.alembic}/bin/alembic -x config='${matrix-registration-config}' upgrade head
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

        LoadCredential = (if cfg.credentialsFile != null then "secrets:${cfg.credentialsFile}" else null);

        ExecStart = ''
          ${pkgs.matrix-registration}/bin/matrix-registration \
            --config-path="${matrix-registration-config}" \
        '' + strings.optionalString (cfg.credentialsFile != null) ''
            --secrets-path="$CREDENTIALS_DIRECTORY/secrets" \
        '' + "serve"
        ;
      };
    };

    environment.systemPackages = [ matrix-registration-cli-wrapper ];
  };

  # meta.maintainers = with maintainers; [ zeratax ];
}
