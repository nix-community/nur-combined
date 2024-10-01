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
                              handler = "encode";
                              encodings = {
                                zstd = {
                                  level = "better";
                                };
                              };
                            }
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
                      handler = "encode";
                      encodings = {
                        zstd = {
                          level = "better";
                        };
                      };
                    }
                    {
                      handler = "reverse_proxy";
                      upstreams = [ { dial = "localhost:9000"; } ];
                    }
                  ];
                  match = [ { host = [ "s3.nyaw.xyz" ]; } ];
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
}
