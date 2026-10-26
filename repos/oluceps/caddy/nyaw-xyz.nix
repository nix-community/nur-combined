{
  pkgs,
  ...
}:
[
  (import ./immich.nix {
    basicAuthAccounts = [
      {
        username = "immich";
        password = "$2b$05$9CaXvrYtguDwi190/llO9.qytgqCyPp1wqyO0.umxsTEfKkhpwr4q";
      }
    ];
  })
  {
    handle = [
      {
        handler = "reverse_proxy";
        upstreams = [ { dial = "unix//run/realm/caddy/egress/internal-https.sock"; } ];
        transport = {
          protocol = "http";
          tls.server_name = "seed.nyaw.xyz";
        };
      }
    ];
    match = [ { host = [ "seed.nyaw.xyz" ]; } ];
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
                    Access-Control-Allow-Origin = [ "https://blog.nyaw.xyz" ];
                  };
                };
              }
              {
                handler = "headers";
                response = {
                  set = {
                    Access-Control-Allow-Credentials = [ "true" ];
                  };
                };
              }
            ];
            match = [
              {
                header = {
                  Origin = [ "https://blog.nyaw.xyz" ];
                };
              }
            ];
          }
          {
            handle = [
              {
                handler = "reverse_proxy";
                upstreams = [
                  { dial = "unix//run/realm/caddy/egress/internal-https.sock"; }
                ];
                transport = {
                  protocol = "http";
                  tls.server_name = "heartrate.nyaw.xyz";
                };
              }
            ];
          }
        ];
      }
    ];
    match = [
      {
        host = [ "heartrate.nyaw.xyz" ];
      }
    ];
    terminal = true;
  }
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
        upstreams = [ { dial = "unix//run/realm/caddy/egress/internal-https.sock"; } ];
        transport = {
          protocol = "http";
          tls.server_name = "alert.nyaw.xyz";
        };
      }
    ];
    match = [ { host = [ "alert.nyaw.xyz" ]; } ];
  }
  {
    match = [ { host = [ "oidc.nyaw.xyz" ]; } ];
    handle = [
      {
        handler = "reverse_proxy";
        upstreams = [ { dial = "unix//run/realm/caddy/egress/internal-https.sock"; } ];
        transport = {
          protocol = "http";
          tls.server_name = "oidc.nyaw.xyz";
        };
        response_buffers = 2097152;
      }
    ];
    terminal = true;
  }
  {
    match = [ { host = [ "vault.nyaw.xyz" ]; } ];
    handle = [
      {
        handler = "subroute";
        routes = [
          {
            handle = [
              {
                handler = "static_response";
                status_code = 404;
              }
            ];
            match = [
              {
                path = [
                  "/admin"
                  "/admin/*"
                ];
              }
            ];
          }

          {
            handle = [
              {
                handler = "reverse_proxy";
                headers.request.set.X-Real-Ip = [ "{http.request.remote.host}" ];
                upstreams = [ { dial = "unix//run/realm/caddy/egress/vaultwarden.sock"; } ];
              }
            ];
          }
        ];
      }

    ];
    terminal = true;
  }
  {
    handle = [
      {
        handler = "reverse_proxy";
        upstreams = [ { dial = "unix//run/realm/caddy/egress/s3.sock"; } ];
      }
    ];
    match = [ { host = [ "s3.nyaw.xyz" ]; } ];
    terminal = true;
  }
  {
    handle = [
      {
        handler = "reverse_proxy";
        upstreams = [ { dial = "unix//run/realm/caddy/egress/internal-https.sock"; } ];
        transport = {
          protocol = "http";
          tls = {
            server_name = "memos.nyaw.xyz";
          };
        };
      }
    ];
    match = [ { host = [ "memos.nyaw.xyz" ]; } ];
    terminal = true;
  }
  {
    handle = [
      {
        body = "User-agent: *\\nDisallow: /";
        handler = "static_response";
      }
    ];
    match = [
      {
        host = [ "book.nyaw.xyz" ];
        path = [ "/robots.txt" ];
      }
    ];
  }
  {
    handle = [
      {
        headers = {
          request = {
            set = {
              "X-Robots-Tag" = [ "noindex, nofollow" ];
              "X-Scheme" = [
                "https"
              ];
            };
          };
        };
        upstreams = [ { dial = "unix//run/realm/caddy/egress/calibre.sock"; } ];
        handler = "reverse_proxy";
      }
    ];
    match = [ { host = [ "book.nyaw.xyz" ]; } ];
    terminal = true;
  }
  (import ./matrix.nix {
    inherit pkgs;
    matrix-upstream = "unix//run/realm/caddy/egress/synapse.sock";
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
                upstreams = [ { dial = "unix//run/realm/caddy/egress/meilisearch.sock"; } ];
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
        handler = "reverse_proxy";
        upstreams = [ { dial = "unix//run/realm/caddy/egress/grafana.sock"; } ];
      }
    ];
    match = [ { host = [ "gf.nyaw.xyz" ]; } ];
    terminal = true;
  }
]
