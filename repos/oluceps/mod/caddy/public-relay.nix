{
  flake.modules.nixos.caddy-public-relay =
    { config, pkgs, ... }:
    {
      # Only the Caddy proxy account can reach this backend socket. It is
      # separate from the internal entrypoint and keeps the public route ACLs.
      realm.workloads.caddy = {
        isolation.runtimePaths = [ "/run/realm/caddy/public" ];
        ingress.public-relay = {
          port = 19445;
          backend = {
            kind = "unix";
            path = "/run/realm/caddy/public/http.sock";
          };
          service = "public-http";
          allow.identities = config.realm.caddy.allowedIDs.public-http;
        };
      };
      systemd.tmpfiles.rules = [ "d /run/realm/caddy/public 2750 caddy realm-caddy -" ];
      caddy.settings.apps.http.servers.public-relay = {
        listen = [ "unix//run/realm/caddy/public/http.sock|0660" ];
        protocols = [ "h1" ];
        automatic_https.disable = true;
        trusted_proxies_unix = true;
        trusted_proxies_strict = 1;
        routes = import ../../caddy/nyaw-xyz.nix { inherit pkgs; } ++ [
          (import ../../caddy/nyaw-xyz-zone-apex.nix)
          {
            match = [ { host = [ "api.atuin.nyaw.xyz" ]; } ];
            handle = [
              {
                handler = "reverse_proxy";
                upstreams = [ { dial = "unix//run/realm/caddy/egress/atuin.sock"; } ];
              }
            ];
            terminal = true;
          }
          {
            match = [ { host = [ "pb.nyaw.xyz" ]; } ];
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
                    key = "{http.request.client_ip}";
                    window = "5s";
                    max_events = 5;
                  };
                };
              }
              {
                handler = "reverse_proxy";
                upstreams = [ { dial = "unix//run/realm/caddy/egress/rustypaste.sock"; } ];
              }
            ];
            terminal = true;
          }
          {
            handle = [
              {
                handler = "static_response";
                status_code = 404;
              }
            ];
            terminal = true;
          }
        ];
      };
    };
}
