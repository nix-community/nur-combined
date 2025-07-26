{
  pkgs,
  lib,
  config,
  ...
}:
{
  systemd.services.caddy.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];
  systemd.services.caddy.serviceConfig.SupplementaryGroups = [ "misskey" ];
  repack.caddy = {
    enable = true;
    settings.apps = {
      http.servers.srv0 = {
        routes = [
          {
            handle = [
              {
                handler = "subroute";
                routes = [
                  {
                    handle = [
                      {
                        handler = "subroute";
                        routes = [
                          {
                            handle = [
                              {
                                handler = "authentication";
                                providers.http_basic.accounts = [
                                  {
                                    username = "prometheus";
                                    password = "$2b$05$9CaXvrYtguDwi190/llO9.qytgqCyPp1wqyO0.umxsTEfKkhpwr4q";
                                  }
                                ];
                              }
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
                    match = [ { host = [ config.networking.fqdn ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:8333"; } ];
                      }
                    ];
                    match = [ { host = [ "s3.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:9333"; } ];
                      }
                    ];
                    match = [ { host = [ "seaweedfs.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:5230"; } ];
                      }
                    ];
                    match = [ { host = [ "memos.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:2283"; } ];
                      }
                    ];
                    match = [ { host = [ "photo.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:7700"; } ];
                      }
                    ];
                    match = [ { host = [ "ms.nyaw.xyz" ]; } ];
                  }
                  # {
                  #   handle = [
                  #     {
                  #       handler = "reverse_proxy";
                  #       upstreams = [ { dial = "localhost:3004"; } ];
                  #     }
                  #   ];
                  #   match = [ { host = [ "linkwarden.nyaw.xyz" ]; } ];
                  # }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:8090"; } ];
                      }
                    ];
                    match = [ { host = [ "scrutiny.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:1411"; } ];
                        response_buffers = 2097152;
                      }
                    ];
                    match = [ { host = [ "oidc.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:5244"; } ];
                      }
                    ];
                    match = [ { host = [ "alist.nyaw.xyz" ]; } ];
                  }
                  # {
                  #   handle = [
                  #     {
                  #       handler = "reverse_proxy";
                  #       upstreams = [ { dial = "localhost:9001"; } ];
                  #       rewrite.strip_path_prefix = "/minio";
                  #     }
                  #   ];
                  #   match = [
                  #     {
                  #       host = [ "eihort.nyaw.xyz" ];
                  #       path = [ "/minio/*" ];
                  #     }
                  #   ];
                  # }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        headers = {
                          request = {
                            set = {
                              "X-Scheme" = [
                                "https"
                              ];
                            };
                          };
                        };
                        upstreams = [ { dial = "[::1]:8083"; } ];
                      }
                    ];
                    match = [ { host = [ "book.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:3002"; } ];
                      }
                    ];
                    match = [ { host = [ "gf.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  (import ../caddy-matrix.nix {
                    inherit pkgs;
                    matrix-upstream = "localhost:6167";
                  })
                ];
              }
            ];
            match = [ { host = [ "*.nyaw.xyz" ]; } ];
          }
          {
            handle = [
              {
                handler = "reverse_proxy";
                upstreams = [ { dial = "127.1:3012"; } ];
                # upstreams = [ { dial = "unix//run/misskey/rw.sock"; } ];
                trusted_proxies = [
                  "fdcc::4"
                ];
              }
            ];
            match = [ { host = [ "nyaw.xyz" ]; } ];
          }
        ];

        tls_connection_policies = [
          {
            match = {
              sni = [
                "*.nyaw.xyz"
                "nyaw.xyz"
              ];
            };
            certificate_selection = {
              any_tag = [ "cert0" ];
            };
            protocol_min = "tls1.3";
          }
        ];
      };

      tls = {
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
}
