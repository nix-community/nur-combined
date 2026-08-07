{
  pkgs,
  lib,
  config,
  ...
}:

# TODO: support config reload

let
  inherit (lib)
    # keep-sorted start
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    types
    # keep-sorted end
    ;

  inherit (types)
    # keep-sorted start
    attrs
    attrsOf
    bool
    int
    listOf
    nullOr
    path
    str
    submodule
    # keep-sorted end
    ;

  cfg = config.services.venator;

  configFormat = pkgs.formats.yaml { };
in
{
  options.services.venator = {
    enable = mkEnableOption "venator, a Matrix homeserver written from scratch in Go";
    package = mkPackageOption pkgs "venator" { };
    configurePostgres = mkEnableOption "postgres locally using services.postgresql";
    enableWrapper = mkOption {
      description = "Whether to add a wrapped venatorctl to the path that refers to the server's config file";
      type = bool;
      default = true;
      example = false;
    };
    dismissWrapperWarning = mkEnableOption "dismissal of the warning you get when enabling the wrapper without admin secrets";
    configFile = mkOption {
      description = "file that contains the server config, overrides services.venator.settings!";
      type = path;
      default = configFormat.generate "venator.yaml" cfg.settings;
      defaultText = "<<generated YAML from services.venator.settings>>";
    };
    settings = mkOption {
      description = "venator server config";
      type = submodule {
        freeformType = attrs;
        options = {
          database = {
            url = mkOption {
              description = "Database URL";
              type = nullOr str;
              example = "postgresql://venator:venator@localhost:5432/venator?sslmode=disable";
              default = null;
            };
            urlFile = mkOption {
              description = "Path to a file containing the PostgreSQL database URL";
              type = nullOr path;
              example = "/path/to/postgresql-url";
              default = null;
            };
          };
          listeners = mkOption {
            description = "(federation) listeners";
            type = listOf (submodule {
              options = {
                port = mkOption {
                  description = "port";
                  type = int;
                  example = 8448;
                };
                tls = mkEnableOption "tls";
              };
            });
            default = [
              {
                port = 8008;
                tls = false;
              }
              {
                port = 8448;
                tls = false;
              }
            ];
          };

          logging.writers = mkOption {
            description = ''
              List of log writers for Venator to use.

              The full schema can be found at <https://pkg.go.dev/go.mau.fi/zeroconfig#readme-config-reference>.
            '';
            type = listOf (submodule {
              freeformType = attrsOf str;
              options = {
                type = mkOption {
                  description = "The type of writer to use";
                  type = str;
                  default = "stdout";
                  example = "file";
                };
              };
            });
            default = [
              {
                type = "stdout";
                format = "pretty-colored";
              }
            ];
          };
          registration = {
            enabled = mkOption {
              description = "whether to enable registration";
              type = bool;
              default = true;
              example = false;
            };
            admin_pre_shared_secret_file = mkOption {
              description = "Path to a file containing the admin pre-shared secret.";
              type = nullOr path;
              default = null;
            };
            admin_pre_shared_secret = mkOption {
              description = ''
                The admin pre-shared secret as text.

                ::: {.warning}
                Please note that this copies the admin pre-shared secret into the world-readable Nix store.
                It is recommended to use `admin_pre_shared_secret_file` instead.
                :::
              '';
              type = nullOr str;
              default = null;
            };
            requires_token = mkOption {
              description = "Whether registration requires a token";
              type = bool;
              default = true;
              example = false;
            };
          };
          server_name = mkOption {
            description = "Name of the server";
            type = str;
            example = "venator.localhost:8008";
          };
        };
      };
      default = { };
      example = {
        registration = {
          enabled = true;
          admin_pre_shared_secret = "foobar";
          token = "foobar";
        };
        server_name = "venator.example.com";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.settings.database.url == null) != (cfg.settings.database.urlFile == null);
        message = "Exactly one of database.url or database.urlFile must be set, but not both!";
      }
      {
        assertion =
          (cfg.settings.registration.admin_pre_shared_secret_file == null)
          || (cfg.settings.registration.admin_pre_shared_secret == null);
        message = "Only one of settings.registration.admin_pre_shared_secret_file and settings.registration.admin_pre_shared_secret may be set, not both!";
      }
    ];

    warnings =
      (optional (cfg.settings.registration.admin_pre_shared_secret != null) ''
        settings.registration.admin_pre_shared_secret is set.

        This copies the admin pre-shared secret into the world-readable Nix store.
        You should never do this in a production setup! It is recommended to use `admin_pre_shared_secret_file` instead.
      '')
      ++
        optional
          (
            cfg.settings.registration.admin_pre_shared_secret == null
            && cfg.settings.registration.admin_pre_shared_secret_file == null
            && cfg.enableWrapper
            && !cfg.dismissWrapperWarning
          )
          ''
            Neither settings.registration.admin_pre_shared_secret nor settings.registration.admin_pre_shared_secret_file is set.

            This means that the wrapper generated by the enableWrapper option will not function properly.
            To disable this warning, set `dismissWrapperWarning = true;`.
          '';

    services.venator.settings.database.url =
      mkIf cfg.configurePostgres "postgresql://venator?host=/var/run/postgresql";

    systemd.services.venator = {
      description = "Matrix Venator - versatile capital Matrix homeserver written from scratch in mautrix-go";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      requires = optional cfg.configurePostgres "postgresql.target";
      serviceConfig = {
        Type = "notify-reload";
        ExecStart = ''
          ${getExe cfg.package} --config ${cfg.configFile}
        '';
        DynamicUser = true;
        StateDirectory = "venator";
        WorkingDirectory = "/var/lib/venator";
        Restart = "on-failure";
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = 27;
      };
    };

    users.users.venator = {
      isSystemUser = true;
      group = "venator";
      description = "venator";
    };
    users.groups.venator = { };

    services.postgresql = mkIf cfg.configurePostgres {
      enable = true;
      ensureUsers = [
        {
          name = "venator";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "venator" ];
    };

    environment.systemPackages = mkIf cfg.enableWrapper [
      (pkgs.writeShellApplication {
        name = "venatorctl";
        runtimeInputs = [ cfg.package ];
        text = ''
          venatorctl --config ${cfg.configFile} "$@"
        '';
      })
    ];
  };
}
