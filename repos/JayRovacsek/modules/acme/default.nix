{ config, primaryDomain ? "rovacsek.com", tlds ? [ primaryDomain ], ... }:
let
  port = 10080;

  tldCertConfigs = builtins.map (tld: {
    "${tld}" = {
      extraDomainNames = [ "*.${tld}" ];
      listenHTTP = ":${builtins.toString port}";
      reloadServices = [ "nginx" ];
    };
  }) tlds;

  certs = builtins.foldl' (x: y: x // y) { } tldCertConfigs;

  defaults = {
    inherit (config.services.nginx) group;
    email = "acme@${primaryDomain}";
  };
in {
  networking.firewall.allowedTCPPorts = [ port ];

  security.acme = {
    inherit certs defaults;
    acceptTerms = true;
  };
}
