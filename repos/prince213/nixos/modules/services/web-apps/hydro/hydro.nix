{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hydro;
  format = pkgs.formats.json { };
in
{
  options.services.hydro = {
    enable = lib.mkEnableOption "Hydro";
    package = lib.mkPackageOption pkgs "hydro" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8888;
      description = "The port to listen on.";
    };

    database.createLocally = lib.mkEnableOption "creating a local MongoDB server";

    addons = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "${cfg.package}/lib/hydro/packages/ui-default" ];
      description = "Addons to use.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;
        options = {
          protocol = lib.mkOption {
            type = lib.types.str;
            default = "mongodb";
            description = "Database protocol.";
          };

          host = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            description = "Database host.";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 27017;
            description = "Database port.";
          };

          name = lib.mkOption {
            type = lib.types.str;
            default = "hydro";
            description = "Database name.";
          };
        };
      };
      default = { };
      description = "Hydro configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mongodb.enable = lib.mkIf cfg.database.createLocally true;

    environment.systemPackages = [ cfg.package ];

    environment.etc = {
      "hydro/addon.json".source = format.generate "hydro-addon.json" cfg.addons;
      "hydro/config.json".source = format.generate "hydro-config.json" cfg.settings;
    };

    users = {
      groups.hydro = { };
      users.hydro = {
        isSystemUser = true;
        group = "hydro";
        home = "/var/lib/hydro";
      };
    };

    systemd.services.hydro = {
      after = [
        "network.target"
      ]
      ++ lib.optional cfg.database.createLocally "mongodb.service";
      requires = lib.mkIf cfg.database.createLocally [ "mongodb.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "hydro";
        Group = "hydro";

        RuntimeDirectory = "hydro";
        StateDirectory = "hydro";
        CacheDirectory = "hydro";
        ConfigurationDirectory = "hydro";

        ExecStart = "${lib.getExe cfg.package} --port ${toString cfg.port}";
      };
    };
  };
}
