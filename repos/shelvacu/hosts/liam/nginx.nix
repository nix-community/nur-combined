{ ... }:
let
  domains = [
    # keep-sorted start
    "autoconfig.shelvacu.com"
    "imap.shelvacu.com"
    "liam.dis8.net"
    "mail.dis8.net"
    "mail.shelvacu.com"
    "smtp.shelvacu.com"
    # keep-sorted end
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
