{ config, tld ? "rovacsek.com" }:
let
  subdomain = "duplicati";
  fqdn = "${subdomain}.${tld}";
  # TODO: write this out as it's own host in the future.
  target = "dragonite.trust.rovacsek.com.internal";
  port = 8200;
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
    extraConfig = "include /etc/nginx/modules/authelia/authelia-server.conf;";
  };
}
