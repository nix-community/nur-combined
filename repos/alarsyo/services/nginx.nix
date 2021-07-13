# Part of config shamelessly stolen from:
#
# https://github.com/delroth/infra.delroth.net
{ config, lib, pkgs, ... }:
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

    services.prometheus = {
      exporters.nginx = {
        enable = true;
        listenAddress = "127.0.0.1";
      };

      scrapeConfigs = [
        {
          job_name = "nginx";
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }];
        }
      ];
    };

    security.acme = {
      acceptTerms = true;
      email = "antoine97.martin@gmail.com";

      certs =
        let
          domain = config.networking.domain;
          gandiKey = config.my.secrets.gandiKey;
        in {
          "${domain}" = {
            extraDomainNames = [ "*.${domain}" ];
            dnsProvider = "gandiv5";
            credentialsFile = pkgs.writeText "gandi-creds.env" gandiKey;
            group = "nginx";
          };
        };
    };
  };
}
