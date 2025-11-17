{ config, lib, ... }:
let
  cfg = config.my.services.mealie;
in
{
  options.my.services.mealie = with lib; {
    enable = mkEnableOption "Mealie service";

    port = mkOption {
      type = types.port;
      default = 4537;
      example = 8080;
      description = "Internal port for webui";
    };

    credentialsFile = mkOption {
      type = types.str;
      example = "/var/lib/mealie/credentials.env";
      description = ''
        Configuration file for secrets.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.mealie = {
      enable = true;
      inherit (cfg) port credentialsFile;

      settings = {
        # Basic settings
        BASE_URL = "https://mealie.${config.networking.domain}";
        TZ = config.time.timeZone;
        ALLOw_SIGNUP = "false";
        TOKEN_TIME = 24 * 180; # 180 days
      };

      # Automatic PostgreSQL provisioning
      database = {
        createLocally = true;
      };
    };

    my.services.nginx.virtualHosts = {
      mealie = {
        inherit (cfg) port;

        extraConfig = {
          # Allow bulk upload of recipes for import/export
          locations."/".extraConfig = ''
            client_max_body_size 0;
          '';
        };
      };
    };

    services.fail2ban.jails = {
      mealie = ''
        enabled = true
        filter = mealie
        port = http,https
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/mealie.conf".text = ''
        [Definition]
        failregex = ^.*ERROR.*Incorrect username or password from <HOST>
        journalmatch = _SYSTEMD_UNIT=mealie.service
      '';
    };
  };
}
