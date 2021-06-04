# Part of config shamelessly stolen from:
#
# https://github.com/delroth/infra.delroth.net
{ config, lib, ... }:
{
  # Whenever something defines an nginx vhost, ensure that nginx defaults are
  # properly set.
  config = lib.mkIf ((builtins.attrNames config.services.nginx.virtualHosts) != [ "localhost" ]) {
    services.nginx = {
      enable = true;
      statusPage = true; # For monitoring scraping.

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
