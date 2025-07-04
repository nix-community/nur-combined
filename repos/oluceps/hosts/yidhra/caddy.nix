{
  pkgs,
  ...
}:
{

  repack.caddy = {
    enable = true;
    public = true;
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
                                handler = "reverse_proxy";
                                upstreams = [ { dial = "[fdcc::3]:3001"; } ];
                              }
                            ];
                            match = [
                              {
                                path = [
                                  "/share/*"
                                  "/share"
                                ];
                              }
                            ];
                          }
                          {
                            handle = [
                              {
                                handler = "authentication";
                                providers.http_basic.accounts = [
                                  {
                                    username = "immich";
                                    password = "$2b$05$9CaXvrYtguDwi190/llO9.qytgqCyPp1wqyO0.umxsTEfKkhpwr4q";
                                  }
                                ];
                              }
                              {
                                handler = "reverse_proxy";
                                upstreams = [ { dial = "[fdcc::3]:2283"; } ];
                              }
                            ];
                          }
                        ];
                      }

                    ];
                    match = [
                      {
                        host = [ "photo.nyaw.xyz" ];
                      }
                    ];
                    terminal = true;
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
                                upstreams = [ { dial = "[fdcc::3]:443"; } ];
                                transport = {
                                  protocol = "http";
                                  tls = {
                                    server_name = "s3.nyaw.xyz";
                                  };
                                };
                              }
                            ];
                          }
                        ];
                      }
                    ];
                    match = [ { host = [ "s3.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:8003"; } ];
                      }
                    ];
                    match = [ { host = [ "vault.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "rate_limit";
                        rate_limits = {
                          static = {
                            match = [ { method = [ "GET" ]; } ];
                            key = "static";
                            window = "1m";
                            max_events = 10;
                          };
                          dynamic = {
                            key = "{http.request.remote.host}";
                            window = "5s";
                            max_events = 5;
                          };
                        };
                        log_key = true;
                      }
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:8004"; } ];
                      }
                    ];
                    match = [ { host = [ "subs.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "rate_limit";
                        rate_limits = {
                          dynamic = {
                            key = "{http.request.remote.host}";
                            window = "5s";
                            max_events = 50;
                          };
                        };
                        log_key = true;
                      }
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
                        upstreams = [ { dial = "[fdcc::3]:8083"; } ];
                      }
                    ];
                    match = [ { host = [ "book.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  (import ../caddy-matrix.nix {
                    inherit pkgs;
                    matrix-upstream = "[fdcc::3]:6167";
                  })
                  {
                    handle = [
                      {
                        handler = "subroute";
                        routes = [
                          {
                            handle = [
                              {
                                handler = "reverse_proxy";
                                upstreams = [ { dial = "[fdcc::1]:5000"; } ];
                              }
                            ];
                          }
                        ];
                      }
                    ];
                    match = [ { host = [ "cache.nyaw.xyz" ]; } ];
                    terminal = true;
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
                                upstreams = [ { dial = "[fdcc::3]:7700"; } ];
                              }
                            ];
                          }
                        ];
                      }
                    ];
                    match = [ { host = [ "ms.nyaw.xyz" ]; } ];
                    terminal = true;
                  }

                  {
                    handle = [
                      {
                        handler = "rate_limit";
                        rate_limits = {
                          static = {
                            match = [ { method = [ "GET" ]; } ];
                            key = "static";
                            window = "1m";
                            max_events = 60;
                          };
                          dynamic = {
                            key = "{http.request.remote.host}";
                            window = "5s";
                            max_events = 5;
                          };
                        };
                        log_key = true;
                      }
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "127.0.0.1:3999"; } ];
                      }
                    ];
                    match = [ { host = [ "pb.nyaw.xyz" ]; } ];
                    terminal = true;
                  }

                  {
                    handle = [
                      {
                        handler = "subroute";
                        routes = [
                          {
                            handle = [
                              {
                                handler = "static_response";
                                headers = {
                                  Location = [ "https://{http.request.host}{http.request.uri}" ];
                                };
                                status_code = 302;
                              }
                            ];
                            match = [
                              {
                                method = [ "GET" ];
                                path_regexp = {
                                  pattern = "^/([-_a-z0-9]{0,64}$|docs/|static/)";
                                };
                                protocol = "http";
                              }
                            ];
                          }
                          {
                            handle = [
                              {
                                handler = "reverse_proxy";
                                upstreams = [ { dial = "127.0.0.1:2586"; } ];
                              }
                            ];
                          }
                        ];
                      }
                    ];
                    match = [ { host = [ "ntfy.nyaw.xyz" ]; } ];
                    terminal = true;
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
                ];
              }
            ];
            match = [ { host = [ "*.nyaw.xyz" ]; } ];
          }
          {
            handle = [
              {
                handler = "reverse_proxy";
                upstreams = [ { dial = "[fdcc::3]:8888"; } ];
              }
            ];
            match = [ { host = [ "api.atuin.nyaw.xyz" ]; } ];
            terminal = true;
          }
          {
            match = [ { host = [ "oidc.nyaw.xyz" ]; } ];
            handle = [
              {
                handler = "reverse_proxy";
                upstreams = [ { dial = "[fdcc::3]:1411"; } ];
                response_buffers = 2097152;
              }
            ];
            terminal = true;
          }
          {
            handle = [
              {
                handler = "subroute";
                routes = [
                  {
                    handle = [
                      {
                        handler = "headers";
                        response = {
                          set = {
                            Access-Control-Allow-Origin = [ "*" ];
                          };
                        };
                      }
                    ];
                    match = [ { path = [ "/.well-known/matrix/*" ]; } ];
                  }
                  {
                    handle = [
                      {
                        body = builtins.toJSON { "m.server" = "matrix.nyaw.xyz:443"; };
                        handler = "static_response";
                      }
                    ];
                    match = [ { path = [ "/.well-known/matrix/server" ]; } ];
                  }
                  {
                    handle = [
                      {
                        body = builtins.toJSON {
                          "m.server" = {
                            base_url = "https://matrix.nyaw.xyz";
                          };
                          "m.homeserver" = {
                            base_url = "https://matrix.nyaw.xyz";
                          };
                          "org.matrix.msc3575.proxy" = {
                            url = "https://matrix.nyaw.xyz";
                          };
                        };
                        handler = "static_response";
                      }
                    ];
                    match = [ { path = [ "/.well-known/matrix/client" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        transport = {
                          protocol = "http";
                          tls = {
                            server_name = "nyaw.xyz";
                          };
                        };
                        upstreams = [ { dial = "[fdcc::3]:443"; } ];
                      }
                    ];
                  }
                ];
              }
            ];
            match = [ { host = [ "nyaw.xyz" ]; } ];
            terminal = true;
          }
        ];

        tls_connection_policies = [
          {
            match = {
              sni = [
                "*.*.nyaw.xyz"
                "*.nyaw.xyz"
                "nyaw.xyz"
              ];
            };
            protocol_min = "tls1.3";
          }
        ];

      };
      tls =
        let
          dns = {
            name = "cloudflare";
            api_token = "{env.CF_API_TOKEN}";
            zone_token = "{env.CF_ZONE_TOKEN}";
          };
        in
        {
          inherit dns;
          automation.policies = [
            {
              issuers = [
                {
                  module = "acme";
                  email = "mn1.674927211@gmail.com";
                  challenges.dns.provider = dns;
                  preferred_chains.smallest = true;
                }
              ];
              key_type = "p256";
            }
          ];
          encrypted_client_hello.configs = [
            {
              public_name = "nyaw.xyz";
            }
          ];
        };
    };
  };
}
