{ lib, config, ... }: {

  systemd.services.caddy.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];

  repack.caddy = {
    enable = true;
    settings = {
      apps = {
        http.grace_period = "1s";
        http = {
          servers = {
            srv0 = {
              routes = [
                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [{
                        handler = "reverse_proxy";
                        upstreams = [{
                          dial = "localhost:8083";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "attic.nyaw.xyz" ];
                  }];
                  terminal = true;
                }
              ];
              tls_connection_policies = [
                {
                  match = { sni = [ "attic.nyaw.xyz" ]; };
                  certificate_selection = { any_tag = [ "cert0" ]; };
                }
              ];
            };
          };
        };
        tls.certificates.load_files = [
          {
            certificate = "/run/certificates/caddy.service/nyaw.cert";
            key = "/run/certificates/caddy.service/nyaw.key";
            tags = [ "cert0" ];
          }
        ];
      };
    };
  };
}
