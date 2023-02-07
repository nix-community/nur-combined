{ config, tld ? "rovacsek.com" }:
let
  subdomain = "jellyfin";
  fqdn = "${subdomain}.${tld}";
  target = "${subdomain}.${
      if builtins.hasAttr "localDomain" config.networking then
        config.networking.localDomain
      else
        ""
    }";
  port = 8096;
  scheme = "http";
in {
  "${subdomain}.${tld}" = {
    forceSSL = true;
    useACMEHost = tld;
    locations = {
      "/" = {
        proxyPass = "${scheme}://${target}:${builtins.toString port}";
        extraConfig = ''
          proxy_set_header Range $http_range;
          proxy_set_header If-Range $http_if_range;
          include /etc/nginx/modules/authelia/authelia-location.conf;
        '';
        recommendedProxySettings = true;
      };

      "~ (/jellyfin)?/socket" = {
        proxyPass = "${scheme}://${target}:${builtins.toString port}";
        recommendedProxySettings = true;
      };
    };
    extraConfig = "include /etc/nginx/modules/authelia/authelia-server.conf;";
  };
}
