# Configuration shamelessly stolen from [1]
#
# [1]: https://github.com/delroth/infra.delroth.net/blob/master/common/nginx.nix
{ config, lib, pkgs, ... }:

{
  # Whenever something defines an nginx vhost, ensure that nginx defaults are
  # properly set.
  config = lib.mkIf ((builtins.attrNames config.services.nginx.virtualHosts) != [ ]) {
    services.nginx = {
      enable = true;
      statusPage = true; # For monitoring scraping.

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # Nginx needs to be able to read the certificates
    users.users.nginx.extraGroups = [ "acme" ];

    # Use DNS wildcard certificate
    security.acme = {
      email = "bruno.acme@belanyi.fr";
      acceptTerms = true;
      certs =
        let
          domain = config.networking.domain;
          key = config.my.secrets.acme.key;
        in
        with pkgs;
        {
          "${domain}" = {
            extraDomainNames = [ "*.${domain}" ];
            dnsProvider = "gandiv5";
            credentialsFile = writeText "key.env" key; # Unsecure, I don't care.
          };
        };
    };
    # Setup monitoring
    services.grafana.provision.dashboards = [
      {
        name = "NGINX";
        options.path = pkgs.nur.repos.alarsyo.grafanaDashboards.nginx;
        disableDeletion = true;
      }
    ];

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
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };
  };
}
