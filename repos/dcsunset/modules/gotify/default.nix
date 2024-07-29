{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.services.gotify-server;
in {
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "gotify"
      "port"
    ] "Use `services.gotify.environment.GOTIFY_SERVER_PORT` instead.")
  ];

  options.services.gotify-server = {
    enable = mkEnableOption "Gotify webserver";

    package = mkPackageOption pkgs "gotify-server" { };

    environment = mkOption {
      type = types.attrsOf (
        types.oneOf [
          types.str
          types.int
        ]
      );
      default = { };
      example = {
        GOTIFY_SERVER_PORT = 8080;
        GOTIFY_DATABASE_DIALECT = "sqlite3";
      };
      description = ''
        Config environment variables for the gotify-server.
        See https://gotify.net/docs/config for more details.
      '';
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        Files containing additional config environment variables for gotify-server.
        Secrets should be set in environmentFiles instead of environment.
      '';
    };

    stateDirectoryName = mkOption {
      type = types.str;
      default = "gotify-server";
      description = ''
        The name of the directory below {file}`/var/lib` where
        gotify stores its runtime data.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gotify-server = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Simple server for sending and receiving messages";

      environment = lib.mapAttrs (_: toString) cfg.environment;

      serviceConfig = {
        WorkingDirectory = "/var/lib/${cfg.stateDirectoryName}";
        StateDirectory = cfg.stateDirectoryName;
        EnvironmentFile = cfg.environmentFiles;
        Restart = "always";
        DynamicUser = "yes";
        ExecStart = lib.getExe cfg.package;
      };
    };
  };
}
