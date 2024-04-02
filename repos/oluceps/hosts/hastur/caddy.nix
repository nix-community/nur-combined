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
                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [{
                        handler = "reverse_proxy";
                        upstreams = [{
                          dial = "localhost:9000";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "s3.nyaw.xyz" ];
                  }];
                  terminal = true;
                }
              ];
              tls_connection_policies = [
                {
                  match = { sni = [ "attic.nyaw.xyz" "hastur.nyaw.xyz" "s3.nyaw.xyz" ]; };
                  certificate_selection = { any_tag = [ "cert0" ]; };
                }
                # {
                #   match = { sni = [ "api.s3.nyaw.xyz" ]; };
                #   certificate_selection = { any_tag = [ "certs3" ]; };
                # }
              ];
            };
          };
        };
        tls.certificates.load_files = [
          {
            certificate = "/run/credentials/caddy.service/nyaw.cert";
            key = "/run/credentials/caddy.service/nyaw.key";
            tags = [ "cert0" ];
          }
          {
            certificate = "{env.STATE_DIRECTORY}/certificates/acme-v02.api.letsencrypt.org-directory/api.s3.nyaw.xyz/api.s3.nyaw.xyz.crt";
            key = "{env.STATE_DIRECTORY}/certificates/acme-v02.api.letsencrypt.org-directory/api.s3.nyaw.xyz/api.s3.nyaw.xyz.key";
            tags = [ "certs3" ];
          }
        ];
      };
    };
  };
}
