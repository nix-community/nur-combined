{
  pkgs,
  lib,
  config,
  ...
}:
{
  systemd.services.caddy.serviceConfig.SupplementaryGroups = [ "misskey" ];
  repack.caddy = {
    enable = true;
    settings.apps = {
      http.servers.srv0 = {
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
                        upstreams = [ { dial = "[fdcc::3]:8333"; } ];
                      }
                    ];
                    match = [ { host = [ "s3.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:9093"; } ];
                      }
                    ];
                    match = [ { host = [ "alert.nyaw.xyz" ]; } ];
                  }

                  # {
                  #   handle = [
                  #     {
                  #       handler = "subroute";
                  #       routes = [
                  #         {
                  #           handle = [
                  #             {
                  #               handler = "headers";
                  #               response = {
                  #                 replace = {
                  #                   Cache-Control = [
                  #                     {
                  #                       replace = "public, immutable, max-age=31536000";
                  #                       search_regexp = "@static";
                  #                     }
                  #                   ];
                  #                 };
                  #                 set = {
                  #                   "@static" = [ "\\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$" ];
                  #                   X-Content-Type-Options = [ "nosniff" ];
                  #                   X-Frame-Options = [ "SAMEORIGIN" ];
                  #                   X-Xss-Protection = [ "1; mode=block" ];
                  #                 };
                  #               };
                  #             }
                  #           ];
                  #         }
                  #         {
                  #           handle = [
                  #             {
                  #               handler = "rewrite";
                  #               uri = "{http.matchers.file.relative}";
                  #             }
                  #           ];
                  #           match = [
                  #             {
                  #               file = {
                  #                 try_files = [
                  #                   "{http.request.uri.path}"
                  #                   "{http.request.uri.path}/"
                  #                   "/index.html"
                  #                 ];
                  #               };
                  #             }
                  #           ];
                  #         }
                  #         {
                  #           handle = [
                  #             {
                  #               handler = "subroute";
                  #               routes = [
                  #                 {
                  #                   handle = [
                  #                     {
                  #                       handler = "rewrite";
                  #                       strip_path_prefix = "/api";
                  #                     }
                  #                   ];
                  #                 }

                  #               ];
                  #             }
                  #           ];
                  #           match = [
                  #             {
                  #               path = [ "/api/*" ];
                  #             }
                  #           ];
                  #         }
                  #         {
                  #           handle = [
                  #             {
                  #               body = "healthy";
                  #               handler = "static_response";
                  #               status_code = 200;
                  #             }
                  #           ];
                  #           match = [
                  #             {
                  #               path = [ "/health" ];
                  #             }
                  #           ];
                  #         }
                  #         {
                  #           handle = [
                  #             {
                  #               handler = "reverse_proxy";
                  #               upstreams = [
                  #                 { dial = "[fdcc::3]:3335"; }
                  #               ];
                  #             }
                  #           ];
                  #           match = [
                  #             {
                  #               path = [ "/ws*" ];
                  #             }
                  #           ];
                  #         }
                  #         {
                  #           handle = [
                  #             {
                  #               handler = "file_server";
                  #             }
                  #           ];
                  #         }
                  #       ];
                  #     }
                  #   ];
                  #   match = [
                  #     {
                  #       host = [ "tgs.nyaw.xyz" ];
                  #     }
                  #   ];
                  #   terminal = true;
                  # }

                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:3336"; } ];
                      }
                    ];
                    match = [ { host = [ "tgs.nyaw.xyz" ]; } ];
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
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:8096"; } ];
                      }
                    ];
                    match = [ { host = [ "jellyfin.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:9333"; } ];
                      }
                    ];
                    match = [ { host = [ "seaweedfs.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:5230"; } ];
                      }
                    ];
                    match = [ { host = [ "memos.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:2283"; } ];
                      }
                    ];
                    match = [ { host = [ "photo.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:3031"; } ];
                      }
                    ];
                    match = [ { host = [ "rqbit.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:7700"; } ];
                      }
                    ];
                    match = [ { host = [ "ms.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:8090"; } ];
                      }
                    ];
                    match = [ { host = [ "scrutiny.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:1411"; } ];
                        response_buffers = 2097152;
                      }
                    ];
                    match = [ { host = [ "oidc.nyaw.xyz" ]; } ];
                    terminal = true;
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "[fdcc::3]:5244"; } ];
                      }
                    ];
                    match = [ { host = [ "alist.nyaw.xyz" ]; } ];
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
                        upstreams = [ { dial = "[fdcc::3]:8083"; } ];
                        handler = "reverse_proxy";
                      }
                    ];
                    match = [ { host = [ "book.nyaw.xyz" ]; } ];
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
                  (import ../caddy/matrix.nix {
                    inherit pkgs;
                    matrix-upstream = "[fdcc::3]:8196";
                  })
                ];
              }
            ];
            match = [ { host = [ "*.nyaw.xyz" ]; } ];
          }
          {
            handle = [
              {
                handler = "reverse_proxy";
                upstreams = [ { dial = "127.1:3012"; } ];
                # upstreams = [ { dial = "unix//run/misskey/rw.sock"; } ];
                trusted_proxies = [
                  "fdcc::4"
                  "fdcc::5"
                  "fdcc::6"
                ];
              }
            ];
            match = [ { host = [ "nyaw.xyz" ]; } ];
          }
        ];

        tls_connection_policies = [
          {
            match = {
              sni = [
                "*.nyaw.xyz"
                "nyaw.xyz"
              ];
            };
            certificate_selection = {
              any_tag = [ "cert0" ];
            };
            protocol_min = "tls1.3";
          }
        ];
      };

      tls = {
        certificates.load_files = [
          {
            certificate = "/run/credentials/caddy.service/nyaw.cert";
            key = "/run/credentials/caddy.service/nyaw.key";
            tags = [ "cert0" ];
          }
        ];
      };
    };
  };
}
