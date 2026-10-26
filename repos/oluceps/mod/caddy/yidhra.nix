{ self, ... }:
{
  flake.modules.nixos."caddy/yidhra" =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      publicHosts = lib.unique (
        lib.concatMap (route: lib.concatMap (match: match.host or [ ]) (route.match or [ ])) (
          import ../../caddy/nyaw-xyz.nix { inherit pkgs; }
        )
      );
    in
    {
      imports = [ self.modules.nixos.caddy ];
      realm.workloads.caddy.egress.public-http = {
        service = "public-http";
      };
      systemd.services.caddy = {
        environment = {
          GOMEMLIMIT = "48MiB";
          GOGC = "50";
        };
        serviceConfig.MemoryLow = "64M";
      };
      caddy = {
        expose = true;
        settings.apps = {
          http.servers.srv0 = {
            # Offload shared route state and per-backend egress processes.
            # Autopeer keeps its node-local authenticated ingress.
            routes = [
              {
                match = [
                  {
                    host = publicHosts ++ [
                      "nyaw.xyz"
                      "api.atuin.nyaw.xyz"
                      "pb.nyaw.xyz"
                    ];
                  }
                ];
                handle = [
                  {
                    handler = "reverse_proxy";
                    upstreams = [ { dial = "unix//run/realm/caddy/egress/public-http.sock"; } ];
                  }
                ];
                terminal = true;
              }
              (import ../../caddy/dn42-cors.nix {
                hosts = [ "sgp-1.dn42.nyaw.xyz" ];
              })
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
