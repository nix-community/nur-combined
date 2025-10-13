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
        };
      };
      default = { };
      description = "BloodHound CE server configuration (subset).";
    };

    # Database wiring via libpq env vars
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
  };

  ###### implementation ########################################################
  config = lib.mkMerge [

    (lib.mkIf cfg.enable {

      # Put our generated config where the binary expects it by default
      environment.etc."bhapi/bhapi.json".source = json.generate "bhapi.json" {
        Server = {
          Host = cfg.settings.server.host;
          Port = cfg.settings.server.port;
        };
        LogLevel = cfg.settings.logLevel;
        LogPath = cfg.settings.logPath;
      };

      systemd.services.bloodhound-ce = {
        description = "BloodHound Community Edition API";
        wantedBy = [ "multi-user.target" ];

        # if you rely on a local postgres, leave postgresql.service here
        after = [
          "network-online.target"
          "postgresql.service"
        ];
        wants = [ "network-online.target" ];

        serviceConfig = lib.mkMerge [
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
                  "/etc/bhapi/bhapi.json"
                ];
              in
              utils.escapeSystemdExecArgs args;

            Environment = [
              "bhe_work_dir=/var/lib/bloodhound-ce/work"
              "bhe_collectors_base_path=${cfg.package}/share/bloodhound/collectors"
              "BH_POSTGRES_PORT=${cfg.database.host}:${cfg.database.port}"
              "BH_POSTGRES_DB=${cfg.database.name}"
              "BH_POSTGRES_USER=${cfg.database.user}"
            ]
            ++ lib.optional (cfg.database.password != null) "BH_POSTGRES_PASSWORD=${cfg.database.password}";

            # Hardening (reasonable baseline)
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
          (lib.mkIf (cfg.database.passwordFile != null) {
            EnvironmentFile = cfg.database.passwordFile;
          })
        ];
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
