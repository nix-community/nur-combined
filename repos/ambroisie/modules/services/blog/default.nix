# My blog setup
{ config, lib, ... }:
let
  cfg = config.my.services.blog;
  domain = config.networking.domain;

  makeHostInfo = subdomain: {
    inherit subdomain;
    root = "/var/www/${subdomain}";
  };

  hostsInfo = map makeHostInfo [ "cv" "dev" "key" ];
in
{
  options.my.services.blog = {
    enable = lib.mkEnableOption "Blog hosting";
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts = {
      # This is not a subdomain, cannot use my nginx wrapper module
      ${domain} = {
        forceSSL = true;
        useACMEHost = domain;
        root = "/var/www/blog";

        # http://www.gnuterrypratchett.com/
        extraConfig = ''
          add_header X-Clacks-Overhead "GNU Terry Pratchett";
        '';
      };

      # Dummy vhost to redirect all unknown (sub-)domains to my blog
      "_" = {
        forceSSL = true;
        useACMEHost = domain;
        default = true;

        locations."/".return = "302 https://belanyi.fr$request_uri";
      };
    };

    # Those are all subdomains, no problem
    my.services.nginx.virtualHosts = hostsInfo;
  };
}
