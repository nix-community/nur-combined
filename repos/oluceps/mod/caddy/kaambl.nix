{ self, ... }:
{
  flake.modules.nixos."caddy/kaambl" =
    {
      config,
      ...
    }:
    {
      imports = [ self.modules.nixos.caddy ];

      vaultix.secrets."nyaw.key" = {
        mode = "400";
        owner = config.identity.user;
      };
      vaultix.secrets."nyaw.cert" = {
        cleanPlaceholder = true;
        mode = "400";
        owner = config.identity.user;
        insert = {
          "aa778b04d0a03257ce38ecfc17c225fe019a5369d50b2b51a47af2dcc3b446ef" = {
            content = config.fn.pki.intermediate;
          };
        };
      };

      caddy = {
        settings = {
          apps = {
            http.grace_period = "1s";
            http = {
              servers = {
                srv0 = {
                  routes = [
                    {
                      handle = [
                        {
                          handler = "reverse_proxy";
                          headers = {
                            request = {
                              set = {
                                Host = [ "{http.reverse_proxy.upstream.hostport}" ];
                              };
                            };
                          };
                          upstreams = [ { dial = "localhost:8384"; } ];
                        }
                      ];
                      match = [ { host = [ "sync.nyaw.xyz" ]; } ];
                    }
                  ];
                  tls_connection_policies = [
                    {
                      match = {
                        sni = [ "kaambl.nyaw.xyz" ];
                      };
                      certificate_selection = {
                        any_tag = [ "cert0" ];
                      };
                      protocol_min = "tls1.3";
                    }
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
            ];
          };
        };

      };
    };
}
