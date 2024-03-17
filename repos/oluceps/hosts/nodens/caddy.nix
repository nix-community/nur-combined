{ pkgs, config, ... }: {

  services.caddy = {
    enable = true;
    # package = pkgs.caddy-naive;
    settings = {
      admin = {
        listen = "unix//tmp/caddy.sock";
        config.persist = false;
      };
      # logging = {
      #   logs = {
      #     debug = {
      #       level = "debug";
      #     };
      #   };
      # };
      apps = {
        http = {
          servers = {
            srv0 = {
              listen = [ ":443" ];
              strict_sni_host = false;
              metrics = { };
              routes = [

                {
                  match = [{
                    host = [ config.networking.fqdn ];
                    path = [ "/prom" "/prom/*" ];
                  }];
                  handle = [{
                    handler = "reverse_proxy";
                    upstreams = [{ dial = "10.0.1.2:9090"; }];
                  }];
                }

                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [{
                        handler = "reverse_proxy";
                        upstreams = [{
                          dial = "127.0.0.1:7921";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "nai.nyaw.xyz" ];
                  }];
                  terminal = true;
                }

                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [{
                        handler = "reverse_proxy";
                        upstreams = [{
                          dial = "10.0.1.2:3001";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "chat.nyaw.xyz" ];
                  }];
                  terminal = true;
                }

                {
                  match = [{
                    host = [ config.networking.fqdn ];
                    path = [ "/caddy" ];
                  }];
                  handle = [
                    {
                      handler = "authentication";
                      providers.http_basic.accounts = [{
                        username = "prometheus";
                        password = "$2b$05$EGDkhDEoadOvUkJujmyer.944J2Dh4U73TUtb11Z1bVZwd2rjNECO";
                      }];
                    }
                    {
                      handler = "metrics";
                    }
                  ];
                }

                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [{
                        handler = "reverse_proxy";
                        upstreams = [{
                          dial = "10.0.1.2:8888";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "api.atuin.nyaw.xyz" ];
                  }];
                  terminal = true;
                }
                {
                  handle = [{
                    handler = "subroute";
                    routes = [
                      {
                        handle = [{
                          handler = "reverse_proxy";
                          upstreams = [{
                            dial = "10.0.1.2:6167";
                          }];
                        }];
                        match = [{
                          path = [ "/_matrix/*" ];
                        }];
                      }
                      {
                        handle = [
                          {
                            handler = "headers";
                            response.set = {
                              X-Frame-Options = [ "SAMEORIGIN" ];
                              X-Content-Type-Options = [ "nosniff" ];
                              X-XSS-Protection = [ "1; mode=block" ];
                              Content-Security-Policy = [ "frame-ancestors 'self'" ];
                            };
                          }
                          (
                            let
                              conf = {
                                default_server_config = {
                                  "m.homeserver" = {
                                    base_url = "https://matrix.nyaw.xyz";
                                    server_name = "nyaw.xyz";
                                  };
                                };
                                show_labs_settings = true;
                              };
                            in
                            {
                              handler = "file_server";
                              root = "${pkgs.element-web.override { inherit conf; }}";
                            }
                          )
                        ];
                      }
                    ];
                  }];
                  match = [{
                    host = [ "matrix.nyaw.xyz" ];
                  }];
                  terminal = true;
                }
                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [{
                        handler = "reverse_proxy";
                        upstreams = [{
                          dial = "10.0.1.2:8003";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "vault.nyaw.xyz" ];
                  }];
                  terminal = true;
                }
                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [{
                        handler = "reverse_proxy";
                        upstreams = [{
                          dial = "10.0.1.2:10002";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "ctos.magicb.uk" ];
                  }];
                  terminal = true;
                }
                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [
                        {
                          handler = "reverse_proxy";
                          upstreams = [{
                            dial = "127.0.0.1:3999";
                          }];
                        }
                      ];
                    }];
                  }];
                  match = [{
                    host = [ "pb.nyaw.xyz" ];
                  }];
                  terminal = false;
                }

                {
                  handle = [
                    {
                      handler = "subroute";
                      routes = [
                        {
                          handle = [
                            {
                              handler = "static_response";
                              headers = { Location = [ "https://{http.request.host}{http.request.uri}" ]; };
                              status_code = 302;
                            }
                          ];
                          match = [
                            {
                              method = [ "GET" ];
                              path_regexp = { pattern = "^/([-_a-z0-9]{0,64}$|docs/|static/)"; };
                              protocol = "http";
                            }
                          ];
                        }
                        {
                          handle = [
                            {
                              handler = "reverse_proxy";
                              upstreams = [{ dial = "127.0.0.1:2586"; }];
                            }
                          ];
                        }
                      ];
                    }
                  ];
                  match = [{ host = [ "ntfy.nyaw.xyz" ]; }];
                  terminal = true;
                }
                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [
                        {
                          handler = "file_server";
                          hide = [ "/home/riro/c" ];
                          root = "/var/www/public";
                        }
                      ];
                    }];
                  }];
                  match = [{
                    host = [ "magicb.uk" ];
                  }];
                  terminal = true;
                }
                {
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [{
                        handler = "headers";
                        response = {
                          set = {
                            Content-Type = [ "application/json" ];
                          };
                        };
                      }
                        {
                          handler = "headers";
                          response = {
                            set = {
                              Access-Control-Allow-Origin = [ "*" ];
                            };
                          };
                        }];
                      match = [{
                        path = [ "/.well-known/matrix/*" ];
                      }];
                    }
                      {
                        handle = [{
                          handler = "static_response";
                          headers = {
                            Location = [ "https://matrix.to/#/@sec:nyaw.xyz" ];
                          };
                          status_code = 302;
                        }];
                        match = [{
                          path = [ "/matrix" ];
                        }];
                      }
                      {
                        handle = [{
                          body = "{
                            \"m.server\": \"matrix.nyaw.xyz:443\"}";
                          handler = "static_response";
                        }];
                        match = [{
                          path = [ "/.well-known/matrix/server" ];
                        }];
                      }
                      {
                        handle = [{
                          body = "{
                            \"m.homeserver\": {
                            \"base_url\": \"https://matrix.nyaw.xyz\"},\"org.matrix.msc3575.proxy\": {
                            \"url\": \"https://matrix.nyaw.xyz\"}}";
                          handler = "static_response";
                        }];
                        match = [{
                          path = [ "/.well-known/matrix/client" ];
                        }];
                      }
                      {
                        handle = [{
                          handler = "reverse_proxy";
                          upstreams = [{
                            dial = "10.0.1.2:3000";
                          }];
                        }];
                      }];
                  }];
                  match = [{
                    host = [ "nyaw.xyz" ];
                  }];
                  terminal = true;
                }
              ];
              tls_connection_policies = [{
                certificate_selection = {
                  any_tag = [ "cert0" ];
                };
                match = {
                  sni = [ "pb.nyaw.xyz" ];
                };
              }
                {
                  certificate_selection = {
                    any_tag = [ "cert0" ];
                  };
                  match = {
                    sni = [ "nyaw.xyz" ];
                  };
                }
                { }];
            };
          };
        };
        tls = {
          automation = {
            policies = [{
              subjects = [
                "matrix.nyaw.xyz"
                "vault.nyaw.xyz"
                "pb.nyaw.xyz"
                "nyaw.xyz"
                "api.heartrate.nyaw.xyz"
                config.networking.fqdn
              ];
            }
              {
                issuers = [{
                  email = "mn1.674927211@gmail.com";
                  module = "acme";
                }
                  {
                    email = "mn1.674927211@gmail.com";
                    module = "zerossl";
                  }];
                subjects = [ "ctos.magicb.uk" "magicb.uk" ];
              }];
          };
          certificates = {
            load_files = [{
              certificate = "/run/credentials/caddy.service/nyaw.cert";
              key = "/run/credentials/caddy.service/nyaw.key";
              tags = [ "cert0" ];
            }];
          };
        };
      };
    };
  };
}
