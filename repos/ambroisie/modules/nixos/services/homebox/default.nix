# Home inventory made easy
{ config, lib, ... }:
let
  cfg = config.my.services.homebox;
in
{
  options.my.services.homebox = with lib; {
    enable = mkEnableOption "Homebox home inventory";
  };

  config = lib.mkIf cfg.enable {
    services.homebox = {
      enable = true;

      settings = {
        # FIXME: mailer?
        HBOX_WEB_PORT = toString cfg.port;
      };
    };

    my.services.nginx.virtualHosts = {
      homebox = {
        inherit (cfg) port;
      };
    };

    my.services.backup = {
      paths = [
        config.services.homebox.settings.HBOX_STORAGE_DATA
      ];
    };

    # NOTE: unfortunately homebox does not log connection failures for fail2ban
  };
}
