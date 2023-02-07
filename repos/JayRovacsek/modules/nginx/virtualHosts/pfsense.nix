{ config, tld ? "rovacsek.com" }:
let
  subdomain = "pfsense";
  fqdn = "${subdomain}.${tld}";
  # target = "${subdomain}.${
  #     if builtins.hasAttr "localDomain" config.networking then
  #       config.networking.localDomain
  #     else
  #       ""
  #   }";
  # TODO: use the above once I've deployed suitable DNS entries.
  target = "192.168.1.1";
  port = 443;
  scheme = "https";
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
