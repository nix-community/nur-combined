{ lib, pkgs, config, ... }:
let
  cfg = config.services.hatsu;

  sqliteLocal = cfg.database.type == "sqlite" && cfg.database.createLocally;

  env = {
    HATSU_LISTEN_HOST = cfg.host;
    HATSU_LISTEN_PORT = toString cfg.port;
    HATSU_DOMAIN = cfg.domain;
    HATSU_PRIMARY_ACCOUNT = cfg.primaryAccount;
    HATSU_DATABASE_URL = cfg.database.url;
  } // (
    lib.mapAttrs (_: toString) cfg.settings
  );
in
{
  meta.doc = ./hatsu.md;
  meta.maintainers = with lib.maintainers; [ kwaa ];

  options.services.hatsu = {
    enable = lib.mkEnableOption "Self-hosted and fully-automated ActivityPub bridge for static sites";

    package = lib.mkPackageOption pkgs "hatsu" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3939;
      description = "Port where hatsu should listen for incoming requests.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "The domain name of your instance (eg 'hatsu.local').";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/hatsu";
      description = "Hatsu data directory. (for sqlite database only)";
    };

    database = {
      type = lib.mkOption {
        type = lib.types.enum [
          "sqlite"
          "postgres"
        ];
        default = "sqlite";
        description = "Database type.";
      };

      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default =
          if sqliteLocal then
            "sqlite://${cfg.dataDir}/hatsu.sqlite?mode=rwc"
          else null;
        example = "postgres://username:password@host/database";
        description = "Database URL.";
      };

      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to create a local database automatically. (currently only supported for SQLite)";
      };
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        See [Environments](https://hatsu.cli.rs/admins/environments.html) for available settings.
      '';
      example = {
        HATSU_NODE_NAME = "nixos/modules";
        HATSU_NODE_DESCRIPTION = "services/web-apps/hatsu.nix";
      };
    };
  };

  config = lib.mkIf cfg.enable
    {
      systemd.services.hatsu = {
        environment = env;

        description = "Hatsu server";
        documentation = [ "https://hatsu.cli.rs/" ];

        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          DynamicUser = true;
          WorkingDirectory = cfg.dataDir;
          ExecStart = "${lib.getExe cfg.package}";
        };
      };
    };
}
