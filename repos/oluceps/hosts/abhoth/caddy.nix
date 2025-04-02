{
  pkgs,
  lib,
  config,
  ...
}:
{

  repack.caddy = {
    enable = true;
    public = true;
    settings.apps.http.servers = {
      srv0 = {
        routes = [
          {
            handle = [
              {
                handler = "subroute";
                routes = [
                  (import ../caddy-matrix.nix {
                    inherit pkgs;
                    matrix-upstream = "[fdcc::3]:6167";
                  })
                ];
              }
            ];
            match = [ { host = [ "*.nyaw.xyz" ]; } ];
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
      };
    };
  };
}
