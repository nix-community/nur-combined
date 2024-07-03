# Part of config shamelessly stolen from:
#
# https://github.com/delroth/infra.delroth.net
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.services.nginx;
in {
  options.my.services.nginx = {
    enable = mkEnableOption "Nginx reverse proxy";
  };

  # Whenever something defines an nginx vhost, ensure that nginx defaults are
  # properly set.
  config = mkIf (cfg.enable) {
    services.nginx = {
      enable = true;
      statusPage = true; # For monitoring scraping.

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
    };

    networking.firewall.allowedTCPPorts = [80 443];

    services.prometheus = {
      exporters.nginx = {
        enable = true;
        listenAddress = "127.0.0.1";
      };

      scrapeConfigs = [
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}"];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "antoine97.martin@gmail.com";

      certs = let
        domain = config.networking.domain;
        hostname = config.networking.hostName;
        fqdn = "${hostname}.${domain}";
        gandiKey = config.my.secrets.gandiKey;
      in {
        "${fqdn}" = {
          dnsProvider = "ovh";
          credentialsFile = config.age.secrets."ovh/credentials".path;
          group = "nginx";
        };
      };
    };
  };
}
