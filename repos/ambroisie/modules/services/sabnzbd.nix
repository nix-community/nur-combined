# Usenet binary client.
{ config, lib, ... }:
let
  cfg = config.my.services.sabnzbd;

  domain = config.networking.domain;
  sabnzbdDomain = "sabnzbd.${domain}";
  port = 9090; # NOTE: not declaratively set...
in
{
  options.my.services.sabnzbd = with lib; {
    enable = mkEnableOption "SABnzbd binary news reader";
  };

  config = lib.mkIf cfg.enable {
    services.sabnzbd = {
      enable = true;
      group = "media";
    };

    services.nginx.virtualHosts."${sabnzbdDomain}" = {
      forceSSL = true;
      useACMEHost = domain;

      locations."/".proxyPass = "http://127.0.0.1:${toString port}";
    };
  };
}
