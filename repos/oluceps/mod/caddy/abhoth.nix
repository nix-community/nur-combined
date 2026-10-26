{ self, ... }:
{
  flake.modules.nixos."caddy/abhoth" =
    {
      pkgs,
      config,
      ...
    }:
    {
      imports = [ self.modules.nixos.caddy-public ];
      realm.workloads.caddy.egress.stalwart-web = {
        service = "stalwart-web";
      };

      vaultix.secrets."nyaw.key" = {
        mode = "400";
        owner = config.identity.user;
      };
      vaultix.secrets."nyaw.cert" = {
        mode = "400";
        owner = config.identity.user;
      };

      caddy = {
        expose = true;
        settings.apps = {
          http.servers = {
            srv0 = {
              listener_wrappers = [
                {
                  wrapper = "layer4";
                  routes = [
                    {
                      handle = [
                        {
                          handler = "proxy";
                          upstreams = [
                            {
                              dial = [
                                "tcp/127.0.0.1:22024"
                              ];
                            }
                          ];
                        }
                      ];
                      match = [
                        {
                          tls = {
                            sni = [
                              "www.ndl.go.jp"
                            ];
                          };
                        }
                      ];
                    }

                  ];
                }

                { wrapper = "tls"; }
              ];
              routes = [
                {
                  handle = [
                    {
                      handler = "subroute";
                      routes = import ../../caddy/nyaw-xyz.nix { inherit pkgs; } ++ [
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
                              upstreams = [ { dial = "unix//run/realm/caddy/egress/rustypaste.sock"; } ];
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
                                # Metrics and debug paths are served only through the
                                # SPIFFE observation listener, never on the public host.
                                {
                                  handle = [
                                    {
                                      handler = "static_response";
                                      status_code = 403;
                                    }
                                  ];
                                  match = [
                                    {
                                      path = [
                                        "/metrics/prometheus"
                                        "/metrics/prometheus/*"
                                        "/debug/*"
                                      ];
                                    }
                                  ];
                                  terminal = true;
                                }
                                # {
                                #   handle = [
                                #     {
                                #       handler = "rewrite";
                                #       uri = "/jmap/session";
                                #     }
                                #   ];
                                #   match = [ { path = [ "/.well-known/jmap" ]; } ];
                                # }
                                {
                                  handle = [
                                    {
                                      handler = "reverse_proxy";
                                      upstreams = [ { dial = "unix//run/realm/caddy/egress/stalwart-web.sock"; } ];
                                    }
                                  ];
                                }
                              ];
                            }
                          ];
                          match = [ { host = [ "box.nyaw.xyz" ]; } ];
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
                      upstreams = [ { dial = "unix//run/realm/caddy/egress/atuin.sock"; } ];
                    }
                  ];
                  match = [ { host = [ "api.atuin.nyaw.xyz" ]; } ];
                  terminal = true;
                }

                (import ../../caddy/dn42-cors.nix {
                  hosts = [ "jp-tyo-1.dn42.nyaw.xyz" ];
                })
                (import ../../caddy/nyaw-xyz-zone-apex.nix)
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
                    }
                  ];
                  key_type = "p256";
                }
              ];
              # encrypted_client_hello.configs = [
              #   {
              #     public_name = "nyaw.xyz";
              #   }
              # ];
            };
        };

      };
    };
}
