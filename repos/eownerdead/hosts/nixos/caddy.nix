{ pkgs, config, ... }:
let
  sops = config.sops.secrets;

  cfCert = pkgs.fetchurl {
    url = "https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem";
    hash = "sha256-wU/tDOUhDbBxn+oR0fELM3UNwX1gmur0fHXp7/DXuEM=";
  };
in
{
  sops.secrets.eownerdeadDedynIoCertKey.owner = config.services.caddy.user;

  services.caddy = {
    enable = true;
    settings = {
      apps = {
        http.servers = {
          "www.eownerdead.dedyn.io" = {
            listen = [ ":443" ];
            routes = [
              {
                match = [ { host = [ "www.eownerdead.dedyn.io" ]; } ];
                handle = [
                  {
                    handler = "file_server";
                    root = ./www.null.dedyn.io;
                  }
                ];
              }
            ];
            tls_connection_policies = [
              {
                certificate_selection.any_tag = [ "cf" ];
                client_authentication = {
                  trusted_ca_certs_pem_files = [ "${cfCert}" ];
                  mode = "request";
                };
              }
            ];
          };
        };
        tls.certificates.load_files = [
          {
            certificate = ./eownerdead.dedyn.io.pem;
            key = sops.eownerdeadDedynIoCertKey.path;
            tags = [ "cf" ];
          }
        ];
      };
    };
  };
}
