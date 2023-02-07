{ config, tld ? "rovacsek.com" }:
let
  subdomain = "binarycache";
  fqdn = "${subdomain}.${tld}";
  # TODO: write this out as it's own host in the future.
  target = "dragonite.trust.rovacsek.com.internal";
  port = 5000;
  scheme = "http";
in {
  "${fqdn}" = {
    forceSSL = true;
    useACMEHost = tld;
    locations."/" = {
      proxyPass = "${scheme}://${target}:${builtins.toString port}";
      extraConfig = ''
        allow 10.0.0.0/8;
        allow 172.16.0.0/12;
        allow 192.168.0.0/16;
        allow 100.64.0.0/10;
        deny all;
      '';
      recommendedProxySettings = true;
    };
  };
}
