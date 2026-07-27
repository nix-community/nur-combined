{ self, ... }:
{
  flake.modules.nixos."caddy/azasos" =
    {
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.nixos.caddy ];
      caddy = {
        expose = true;
        settings.apps = {
          http.servers.srv0 = {

            # listener_wrappers = [
            #   {
            #     wrapper = "layer4";
            #     routes = [
            #       {
            #         handle = [
            #           {
            #             handler = "proxy";
            #             upstreams = [
            #               {
            #                 dial = [
            #                   "127.0.0.1:4474"
            #                 ];
            #               }
            #             ];
            #           }
            #         ];
            #         match = [
            #           {
            #             tls = {
            #               sni = [
            #                 "www.ndl.go.jp"
            #               ];
            #             };
            #           }
            #         ];
            #       }
            #     ];
            #   }

            #   { wrapper = "tls"; }
            # ];
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
                      }
                    ];
                  }

                ];
                match = [ { host = [ "*.nyaw.xyz" ]; } ];
              }
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
          tls =
            let
              dns = {
                name = "cloudflare";
                api_token = "{env.CF_API_TOKEN}";
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
            };
        };
      };
    };
}
