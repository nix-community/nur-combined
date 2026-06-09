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
            routes = [
              {
                handle = [
                  {
                    handler = "subroute";
                    routes = import ../../caddy/nyaw-xyz.nix { inherit pkgs; };
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
