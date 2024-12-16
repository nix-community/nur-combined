{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.habitica;

  resolvedSettings = {
    BASE_URL = "http://${cfg.hostName}";
    PORT = "/run/habitica/socket";
    NODE_DB_URI = lib.optionalString cfg.mongodb.enable "mongodb://${config.services.mongodb.bind_ip}/${cfg.mongodb.name}?replicaSet=${config.services.mongodb.replSetName}";
    TRUSTED_DOMAINS = "http://${cfg.hostName}";
  } // cfg.settings;

  backendUrl =
    if lib.types.path.check resolvedSettings.PORT then
      "http://unix:${resolvedSettings.PORT}:"
    else
      "http://localhost:${toString resolvedSettings.PORT}";
in
{
  options = {
    services.habitica = {
      enable = lib.mkEnableOption "habitica";

      package = lib.mkPackageOption pkgs "habitica" { };

      hostName = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        example = "habitica.example.org";
        description = "The domain name under which the server is reachable.";
      };

      frontend = {
        package = lib.mkOption {
          type = lib.types.package;
          default = cfg.package.client;
          defaultText = lib.literalExpression "config.services.habitica.package.client";
          apply = pkg: pkg.override { settings = pkg.settings // resolvedSettings; };
          description = "The frontend package to use.";
        };
      };

      apidoc = {
        package = lib.mkOption {
          type = lib.types.package;
          default = cfg.package.apidoc;
          defaultText = lib.literalExpression "config.services.habitica.package.apidoc";
          description = "The apidoc package to use.";
        };
      };

      nginx = {
        enable = (lib.mkEnableOption "serving Habitica through nginx") // {
          default = true;
        };
      };

      mongodb = {
        enable = (lib.mkEnableOption "a local MongoDB database for Habitica") // {
          default = true;
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "habitica";
          description = "The name of the Habitica database.";
        };
      };

      settings = lib.mkOption {
        type =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            str
            path
          ])
          // {
            description = "Node.js nconf value";
          };

        default = { };
        description = "Configuration options to pass to Habitica.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.habitica = {
      wantedBy = [ "default.target" ];
      wants = [ "mongodb.service" ];
      after = [
        "network.target"
        "mongodb.service"
      ];

      serviceConfig = {
        DynamicUser = true;
        Group = lib.mkIf cfg.nginx.enable config.services.nginx.group;
        RuntimeDirectory = "habitica";
        UMask = "0007"; # Unmask group write access to files created by habitica & restrict global access
        ExecStart = lib.getExe cfg.package;
      };

      environment = builtins.mapAttrs (
        name: value: if lib.isStringLike value then value else builtins.toJSON value
      ) resolvedSettings;
    };

    services.nginx = lib.mkIf cfg.nginx.enable {
      enable = true;
      virtualHosts.${cfg.hostName} = {
        locations = {
          "/" = {
            root = cfg.frontend.package;
            tryFiles = "$uri $uri/ /index.html";
          };

          "~ ^/((?:analytics|api|email|export)/.*|logout-server|static/user/auth/local/reset-password-set-new-one)$" =
            {
              proxyPass = backendUrl;
              recommendedProxySettings = true;
            };

          "= /apidoc".return = "301 /apidoc/";
          "^~ /apidoc/".alias = "${cfg.apidoc.package}/";
        };
      };
    };

    services.mongodb = lib.mkIf cfg.mongodb.enable {
      enable = true;

      # Ensure mongodb runs as a replica set to support transactions,
      # but don't override replSetName if it's already defined.
      replSetName = lib.mkDefault "rs";
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
}
