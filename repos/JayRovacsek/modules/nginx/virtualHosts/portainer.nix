{ config, tld ? "rovacsek.com" }:
let
  subdomain = "portainer";
  fqdn = "${subdomain}.${tld}";
  target = "dragonite.trust.rovacsek.com.internal";
  port = 9000;
  scheme = "http";
in {
  "${subdomain}.${tld}" = {
    forceSSL = true;
    useACMEHost = tld;
    locations."/" = {
      proxyPass = "${scheme}://${target}:${builtins.toString port}";
      extraConfig =
        "include /etc/nginx/modules/authelia/authelia-location.conf;";
      recommendedProxySettings = true;
    };

    locations."/api/websocket/" = {
      proxyPass = "${scheme}://${target}:${builtins.toString port}";
      extraConfig =
        "include /etc/nginx/modules/authelia/authelia-location.conf;";
      recommendedProxySettings = true;
    };
  };
}
