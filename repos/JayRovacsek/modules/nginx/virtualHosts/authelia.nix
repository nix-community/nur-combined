{ config, tld ? "rovacsek.com" }:
let
  subdomain = "authelia";
  fqdn = "${subdomain}.${tld}";
  target = "${subdomain}.${
      if builtins.hasAttr "localDomain" config.networking then
        config.networking.localDomain
      else
        ""
    }";
  port = 9091;
  scheme = "http";
in {
  "${fqdn}" = {
    forceSSL = true;
    useACMEHost = tld;
    locations."/" = {
      proxyPass = "${scheme}://${target}:${builtins.toString port}";
      recommendedProxySettings = true;
    };
  };
}
