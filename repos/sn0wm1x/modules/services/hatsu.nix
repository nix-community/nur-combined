{ lib, pkgs, config, ... }:
let
  cfg = config.services.hatsu;

  env = {
    HATSU_LISTEN_HOST = cfg.host;
    HATSU_LISTEN_PORT = toString cfg.port;
    HATSU_DOMAIN = cfg.domain;
    HATSU_PRIMARY_ACCOUNT = cfg.primaryAccount;
    HATSU_DATABASE_URL = cfg.database.url;
    # if cfg.database.url != null
    # then cfg.database.url
    # else (lib.mkIf (cfg.database.createLocally) "postgres:///hatsu?host=/run/postgresql&user=hatsu");
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

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host where hatsu should listen for incoming requests.";
    };

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

    database = {
      type = lib.mkOption {
        type = lib.types.enum [
          "sqlite"
          "postgresql"
        ];
        default = "sqlite";
        description = "Database type.";
      };

      url = lib.mkOption {
        type = lib.types.str;
        description = "Database URL.";
        default = "sqlite:///var/lib/hatsu/db.sqlite?mode=rwc";
        example = "postgres://username:password@host/database";
      };

      # createLocally = lib.mkEnableOption "Whether to create a local database automatically.";
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
      users.groups.hatsu = { };
      users.users.hatsu = {
        group = "hatsu";
        isSystemUser = true;
      };

      systemd.services.hatsu = {
        description = "Hatsu server";
        environment = env;
        documentation = [ "https://hatsu.cli.rs/" ];
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ]; # ++ lib.optional cfg.database.createLocally "postgresql.service";
        # requires = lib.optional cfg.database.createLocally "postgresql.service";
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/hatsu";
          Restart = "on-failure";
          Group = "hatsu";
          User = "hatsu";
          StateDirectory = "hatsu";
        };
      };
    };
}
