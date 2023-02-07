{ config, tld ? "rovacsek.com" }:
let
  subdomain = "template";
  fqdn = "${subdomain}.${tld}";
  # We assume the host we are proxying, to have a hostname matching the
  # subdomain - otherwise change this bad-boy
  target = "${subdomain}.${
      if builtins.hasAttr "localDomain" config.networking then
        config.networking.localDomain
      else
        ""
    }";
  port = 9001;
  scheme = "http";
in {
  "${subdomain}.${tld}" = {
    forceSSL = true;
    useACMEHost = tld;
    locations."/" = {
      proxyPass = "${scheme}://${target}:${builtins.toString port}";
      # This enables authelia on the location. Sometimes APIs need to be exposed without Authelia due to integrations.
      # TODO: In the future we will be able to change this so only tailscale IP ranges
      # can use the endpoint. For now that config exists as below:
      # extraConfig = ''
      #   include /etc/nginx/modules/authelia/authelia-location.conf;
      #   allow 10.0.0.0/8;
      #   allow 172.16.0.0/12;
      #   allow 192.168.0.0/16;
      #   allow 100.64.0.0/10;
      #   deny all;
      # '';
      extraConfig =
        "include /etc/nginx/modules/authelia/authelia-location.conf;";
      # While this is set at config.services.nginx.recommendedProxySettings also
      # we do want it here as an explicit escape hatch if the settings break
      # proxying 
      recommendedProxySettings = true;
    };
    # This enables authelia on the server.
    extraConfig = "include /etc/nginx/modules/authelia/authelia-server.conf;";
  };
}
