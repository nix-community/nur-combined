{
  pkgs,
  ...
}:
{

  repack.caddy = {
    enable = true;
    expose = true;
    settings.apps = {
      http.servers.srv0 = {
        routes = [
          {
            handle = [
              {
                handler = "subroute";
                routes = import ../caddy/nyaw-xyz.nix { inherit pkgs; } ++ [
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
          (import ../caddy/nyaw-xyz-zone-apex.nix)
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
