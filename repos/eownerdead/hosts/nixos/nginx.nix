{ pkgs, config, ... }:
let
  sops = config.sops.secrets;

  cfCert = pkgs.fetchurl {
    url = "https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem";
    hash = "sha256-wU/tDOUhDbBxn+oR0fELM3UNwX1gmur0fHXp7/DXuEM=";
  };

  cfSSLConfig = {
    onlySSL = true;
    sslCertificate = ./eownerdead.dedyn.io.pem;
    sslCertificateKey = sops.eownerdeadDedynIoCertKey.path;
    extraConfig = ''
      ssl_client_certificate ${cfCert};
      ssl_verify_client on;
    '';
  };
in
{
  sops.secrets.eownerdeadDedynIoCertKey.owner = config.services.nginx.user;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
    recommendedBrotliSettings = true;
    additionalModules = with pkgs.nginxModules; [ dav ];
    virtualHosts = {
      "eownerdead.dedyn.io" = cfSSLConfig // {
        locations."/".root = ./www.null.dedyn.io;
      };
      "www.eownerdead.dedyn.io" = cfSSLConfig // {
        locations."/".root = ./www.null.dedyn.io;
      };
      "libretranslate.eownerdead.dedyn.io" = cfSSLConfig;
    };
    enableReload = true;
  };
}
