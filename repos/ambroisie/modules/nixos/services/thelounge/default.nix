# Web IRC client
{ config, lib, ... }:
let
  cfg = config.my.services.thelounge;
in
{
  options.my.services.thelounge = with lib; {
    enable = mkEnableOption "The Lounge, a self-hosted web IRC client";

    port = mkOption {
      type = types.port;
      default = 9050;
      example = 4242;
      description = "The port on which The Lounge will listen for incoming HTTP traffic.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.thelounge = {
      enable = true;
      inherit (cfg) port;

      extraConfig = {
        reverseProxy = true;
      };
    };

    my.services.nginx.virtualHosts = {
      irc = {
        inherit (cfg) port;
        # Proxy websockets for RPC
        websocketsLocations = [ "/" ];

        extraConfig = {
          locations."/".extraConfig = ''
            proxy_read_timeout 1d;
          '';
        };
      };
    };

    services.fail2ban.jails = {
      thelounge = ''
        enabled = true
        filter = thelounge
        port = http,https
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/thelounge.conf".text = ''
        [Definition]
        failregex = Authentication failed for user .* from <HOST>$
                    Authentication for non existing user attempted from <HOST>$
        journalmatch = _SYSTEMD_UNIT=thelounge.service
      '';
    };
  };
}
