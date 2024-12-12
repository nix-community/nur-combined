{ lib, config, ... }:
{

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
                  handle = [
                    {
                      handler = "subroute";
                      routes = [
                        {
                          handle = [
                            {
                              handler = "reverse_proxy";
                              upstreams = [ { dial = "localhost:5000"; } ];
                            }
                          ];
                        }
                      ];
                    }
                  ];
                  match = [ { host = [ "cache.nyaw.xyz" ]; } ];
                }
                {
                  handle = [
                    {
                      handler = "subroute";
                      routes = [
                        {
                          handle = [
                            {
                              handler = "reverse_proxy";
                              upstreams = [ { dial = "localhost:3002"; } ];
                            }
                          ];
                          match = [
                            {
                              path = [
                                "/grafana/*"
                                "/grafana"
                              ];
                            }
                          ];
                        }
                        {
                          handle = [
                            {
                              handler = "reverse_proxy";
                              upstreams = [ { dial = "localhost:9090"; } ];
                            }
                          ];
                          match = [
                            {
                              path = [
                                "/prom/*"
                                "/prom"
                              ];
                            }
                          ];
                        }
                      ];
                    }
                  ];
                  match = [ { host = [ "hastur.nyaw.xyz" ]; } ];
                }
                {
                  handle = [
                    {
                      handler = "reverse_proxy";
                      upstreams = [ { dial = "localhost:9000"; } ];
                    }
                  ];
                  match = [ { host = [ "s3.nyaw.xyz" ]; } ];
                }

                {
                  match = [
                    {
                      host = [ config.networking.fqdn ];
                      path = [
                        "/prom"
                        "/prom/*"
                      ];
                    }
                  ];
                  handle = [
                    {
                      handler = "authentication";
                      providers.http_basic.accounts = [
                        {
                          username = "prometheus";
                          password = "$2b$05$eZjq0oUqZzxgqdRaCRsKROuE96w9Y0aKSri3uGPccckPivESAinB6";
                        }
                      ];
                    }
                    {
                      handler = "reverse_proxy";
                      upstreams = [ { dial = "127.0.0.1:9090"; } ];
                    }
                  ];
                }
              ];
              tls_connection_policies = [
                {
                  match = {
                    sni = [
                      "cache.nyaw.xyz"
                      "hastur.nyaw.xyz"
                      "s3.nyaw.xyz"
                    ];
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
        tls = {
          # automation.policies = [
          #   {
          #     subjects = [
          #       "*.nyaw.xyz"
          #       "nyaw.xyz"
          #     ];
          #     issuers = [
          #       {
          #         module = "acme";
          #         challenges = {
          #           dns = {
          #             provider = {
          #               name = "porkbun";
          #               api_key = "{env.PORKBUN_API_KEY}";
          #               api_secret_key = "{env.PORKBUN_API_SECRET_KEY}";
          #             };
          #           };
          #         };
          #       }
          #     ];
          #   }
          # ];
          certificates.load_files = [
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
