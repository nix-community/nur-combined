{ config, lib, ... }:
let
  cfg = config.my.services.tandoor-recipes;
in
{
  options.my.services.tandoor-recipes = with lib; {
    enable = mkEnableOption "Tandoor Recipes service";

    port = mkOption {
      type = types.port;
      default = 4536;
      example = 8080;
      description = "Internal port for webui";
    };

    secretKeyFile = mkOption {
      type = types.str;
      example = "/var/lib/tandoor-recipes/secret-key.env";
      description = ''
        Secret key as an 'EnvironmentFile' (see `systemd.exec(5)`)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tandoor-recipes = {
      enable = true;

      database = {
        createLocally = true;
      };

      port = cfg.port;
      extraConfig =
        let
          tandoorRecipesDomain = "recipes.${config.networking.domain}";
        in
        {
          # Security settings
          ALLOWED_HOSTS = tandoorRecipesDomain;
          CSRF_TRUSTED_ORIGINS = "https://${tandoorRecipesDomain}";

          # Misc
          TIMEZONE = config.time.timeZone;
        };
    };

    systemd.services = {
      tandoor-recipes = {
        serviceConfig = {
          EnvironmentFile = cfg.secretKeyFile;
        };
      };
    };

    my.services.nginx.virtualHosts = {
      recipes = {
        inherit (cfg) port;

        extraConfig = {
          # Allow bulk upload of recipes for import/export
          locations."/".extraConfig = ''
            client_max_body_size 0;
          '';
        };
      };
    };

    # NOTE: unfortunately tandoor-recipes does not log connection failures for fail2ban
  };
}
