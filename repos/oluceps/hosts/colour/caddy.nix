{ lib, config, ... }: {

  systemd.services.caddy.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];
  services.caddy = {
    enable = true;
    # package = pkgs.caddy-naive;
    settings = {
      admin = {
        listen = "unix//tmp/caddy.sock";
        config.persist = false;
      };
      apps = {
        http.grace_period = "1s";
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
                    upstreams = [{ dial = "10.0.2.2:9090"; }];
                  }];
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
                          dial = "10.0.2.3:7001";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "dokidoki.nyaw.xyz" ];
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
                          dial = "10.0.2.3:7000";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "api.heartrate.nyaw.xyz" ];
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
                          dial = "10.0.2.2:3001";
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
                  handle = [{
                    handler = "subroute";
                    routes = [{
                      handle = [{
                        handler = "reverse_proxy";
                        upstreams = [{
                          dial = "10.0.2.2:8888";
                        }];
                      }];
                    }];
                  }];
                  match = [{
                    host = [ "api.atuin.nyaw.xyz" ];
                  }];
                  terminal = true;
                }
              ];
              tls_connection_policies = [
                {
                  certificate_selection = {
                    any_tag = [ "cert0" ];
                  };
                  match = {
                    sni = [ "nyaw.xyz" ];
                  };
                }
                { }
              ];
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
                "api.atuin.nyaw.xyz"
                "chat.nyaw.xyz"
                config.networking.fqdn
              ];
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
