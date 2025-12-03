{ ... }:
let
  domains = [
    "smtp.shelvacu.com"
    "imap.shelvacu.com"
    "mail.shelvacu.com"
    "autoconfig.shelvacu.com"
    "mail.dis8.net"
    "liam.dis8.net"
  ];
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  security.acme.acceptTerms = true;
  security.acme.defaults.webroot = "/var/lib/acme/acme-challenge";
  security.acme.defaults.email = "shelvacu@gmail.com";
  services.nginx = {
    enable = true;
    recommendedZstdSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;

    enableReload = true;

    virtualHosts."liam.dis8.net" = {
      serverAliases = domains;
      forceSSL = true;
      enableACME = true;
      default = true;
    };
  };
}
