{ config, tld ? "rovacsek.com" }:
let
  subdomain = "prowlarr";
  fqdn = "${subdomain}.${tld}";
  target = "${subdomain}.${
      if builtins.hasAttr "localDomain" config.networking then
        config.networking.localDomain
      else
        ""
    }";
  port = 9696;
  scheme = "http";
in {
  "${subdomain}.${tld}" = {
    forceSSL = true;
    useACMEHost = tld;
    locations = {
      "/" = {
        proxyPass = "${scheme}://${target}:${builtins.toString port}";
        extraConfig =
          "include /etc/nginx/modules/authelia/authelia-location.conf;";
        recommendedProxySettings = true;
      };

      "~ (/prowlarr)?(/[0-9]+)?/api" = {
        proxyPass = "${scheme}://${target}:${builtins.toString port}";
        recommendedProxySettings = true;
      };
    };
    extraConfig = "include /etc/nginx/modules/authelia/authelia-server.conf;";
  };
}
