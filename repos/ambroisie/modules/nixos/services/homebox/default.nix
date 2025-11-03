# Home inventory made easy
{ config, lib, ... }:
let
  cfg = config.my.services.homebox;
in
{
  options.my.services.homebox = with lib; {
    enable = mkEnableOption "Homebox home inventory";

    port = mkOption {
      type = types.port;
      default = 7745;
      example = 8080;
      description = "Internal port for webui";
    };
  };

  config = lib.mkIf cfg.enable {
    services.homebox = {
      enable = true;

      # Automatic PostgreSQL provisioning
      database = {
        createLocally = true;
      };

      settings = {
        # FIXME: mailer?
        HBOX_WEB_PORT = toString cfg.port;
      };
    };

    my.services.nginx.virtualHosts = {
      homebox = {
        inherit (cfg) port;
        websocketsLocations = [ "/api" ];
      };
    };

    my.services.backup = {
      paths = [
        (lib.removePrefix "file://" config.services.homebox.settings.HBOX_STORAGE_CONN_STRING)
      ];
    };

    # NOTE: unfortunately homebox does not log connection failures for fail2ban
  };
}
