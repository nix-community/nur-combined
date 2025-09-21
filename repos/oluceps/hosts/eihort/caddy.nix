{
  pkgs,
  lib,
  config,
  ...
}:
{
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
                                upstreams = [ { dial = "[fdcc::3]:9090"; } ];
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
                        upstreams = [ { dial = "[fdcc::3]:8333"; } ];
                      }
                    ];
                    match = [ { host = [ "s3.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:9093"; } ];
                      }
                    ];
                    match = [ { host = [ "alert.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:8084"; } ];
                      }
                    ];
                    match = [ { host = [ "seed.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:9333"; } ];
                      }
                    ];
                    match = [ { host = [ "seaweedfs.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:5230"; } ];
                      }
                    ];
                    match = [ { host = [ "memos.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:2283"; } ];
                      }
                    ];
                    match = [ { host = [ "photo.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:3030"; } ];
                      }
                    ];
                    match = [ { host = [ "rqbit.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:7700"; } ];
                      }
                    ];
                    match = [ { host = [ "ms.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:8090"; } ];
                      }
                    ];
                    match = [ { host = [ "scrutiny.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:1411"; } ];
                        response_buffers = 2097152;
                      }
                    ];
                    match = [ { host = [ "oidc.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:5244"; } ];
                      }
                    ];
                    match = [ { host = [ "alist.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
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
                        upstreams = [ { dial = "[fdcc::3]:3002"; } ];
                      }
                    ];
                    match = [ { host = [ "gf.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  (import ../caddy/matrix.nix {
                    inherit pkgs;
                    matrix-upstream = "[fdcc::3]:8196";
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
