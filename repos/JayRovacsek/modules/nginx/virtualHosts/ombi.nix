{ config, tld ? "rovacsek.com" }:
let
  subdomain = "ombi";
  fqdn = "${subdomain}.${tld}";
  target = "${subdomain}.${
      if builtins.hasAttr "localDomain" config.networking then
        config.networking.localDomain
      else
        ""
    }";
  port = 3579;
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

      "~ (/ombi)?/api" = {
        proxyPass = "${scheme}://${target}:${builtins.toString port}";
        recommendedProxySettings = true;
      };

      "~ (/ombi)?/swagger" = {
        proxyPass = "${scheme}://${target}:${builtins.toString port}";
        recommendedProxySettings = true;
      };
    };
    extraConfig = ''
      include /etc/nginx/modules/authelia/authelia-server.conf;
      if ($http_referer ~* /ombi) {
          rewrite ^/swagger/(.*) /ombi/swagger/$1? redirect;
      }
    '';
  };
}
