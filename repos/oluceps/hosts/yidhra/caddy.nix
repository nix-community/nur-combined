{
  pkgs,
  ...
}:
{

  repack.caddy = {
    enable = true;
    settings.apps = {
      http.servers.srv0.routes = [
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
                              upstreams = [ { dial = "10.0.4.6:9000"; } ];
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
                      upstreams = [ { dial = "10.0.4.6:8003"; } ];
                    }
                  ];
                  match = [ { host = [ "vault.nyaw.xyz" ]; } ];
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
                      upstreams = [ { dial = "10.0.4.6:8083"; } ];
                    }
                  ];
                  match = [ { host = [ "book.nyaw.xyz" ]; } ];
                  terminal = true;
                }
                (import ../caddy-matrix.nix {
                  inherit pkgs;
                  matrix-upstream = "10.0.4.6:6167";
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
                              transport = {
                                protocol = "http";
                                tls = {
                                  server_name = "cache.nyaw.xyz";
                                };
                              };
                              upstreams = [ { dial = "10.0.4.2:443"; } ];
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
                          max_events = 2;
                        };
                      };
                      distributed = { };
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
                      upstreams = [ { dial = "10.0.4.6:8084"; } ];
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
              upstreams = [ { dial = "10.0.4.6:8888"; } ];
            }
          ];
          match = [ { host = [ "api.atuin.nyaw.xyz" ]; } ];
          terminal = true;
        }

        # {
        #   handle = [
        #     {
        #       handler = "reverse_proxy";
        #       upstreams = [ { dial = "10.0.4.6:2283"; } ];
        #     }
        #   ];
        #   match = [ { host = [ "photo.nyaw.xyz" ]; } ];
        #   terminal = true;
        # }
        {
          handle = [
            {
              handler = "subroute";
              routes = [
                {
                  handle = [
                    {
                      handler = "reverse_proxy";
                      upstreams = [ { dial = "10.0.4.6:3001"; } ];
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
                          password = "$2b$05$bKuO7ehC6wKR28/pfhJZOuNyQFUtF7FwhkPFLwcbCMhfLRNUV54vm";
                        }
                      ];
                    }
                    {
                      handler = "reverse_proxy";
                      upstreams = [ { dial = "10.0.4.6:2283"; } ];
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
                      upstreams = [ { dial = "10.0.4.6:3000"; } ];
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

      tls.automation.policies = [
        {
          subjects = [
            "*.nyaw.xyz"
            "nyaw.xyz"
          ];
          issuers = [
            {
              module = "acme";
              challenges = {
                dns = {
                  provider = {
                    name = "porkbun";
                    api_key = "{env.PORKBUN_API_KEY}";
                    api_secret_key = "{env.PORKBUN_API_SECRET_KEY}";
                  };
                };
              };
            }
          ];
        }
      ];
    };
  };
}
