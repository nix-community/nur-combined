{ pkgs, ... }:
[
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
        upstreams = [ { dial = "[fdcc::3]:9093"; } ];
      }
    ];
    match = [ { host = [ "alert.nyaw.xyz" ]; } ];
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
    match = [ { host = [ "s3.nyaw.xyz" ]; } ];
    terminal = true;
  }
  {
    handle = [
      {
        handler = "reverse_proxy";
        upstreams = [ { dial = "[fdcc::3]:443"; } ];
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
                        handler = "subroute";
                        routes = [
                          {
                            handle = [
                              {
                                handler = "authenticator";
                                portal_name = "myportal";
                                route_matcher = "*";
                              }
                            ];
                          }
                        ];
                      }
                    ];
                    match = [
                      {
                        path = [ "*" ];
                      }
                    ];
                  }
                ];
              }
            ];
            match = [
              {
                path = [ "/caddy-security/*" ];
              }
            ];
          }
          {
            handle = [
              {
                handler = "subroute";
                routes = [
                  {
                    handle = [
                      {
                        handler = "authentication";
                        providers = {
                          authorizer = {
                            gatekeeper_name = "mypolicy";
                            route_matcher = "*";
                          };
                        };
                      }
                      {
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
                        handler = "reverse_proxy";
                      }
                    ];
                  }
                ];
              }
            ];
            match = [
              {
                path = [ "/*" ];
              }
            ];
          }
        ];
      }
    ];
    match = [
      {
        host = [ "book.nyaw.xyz" ];
      }
    ];
    terminal = true;
  }
  (import ./matrix.nix {
    inherit pkgs;
    matrix-upstream = "[fdcc::3]:8196";
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
        handler = "reverse_proxy";
        upstreams = [ { dial = "[fdcc::3]:3002"; } ];
      }
    ];
    match = [ { host = [ "gf.nyaw.xyz" ]; } ];
    terminal = true;
  }
]
