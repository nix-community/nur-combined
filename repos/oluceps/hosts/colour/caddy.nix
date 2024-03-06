{ lib, config, pkgs, ... }: {

  systemd.services.caddy.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];
  services.caddy = {
    enable = true;
    package = pkgs.caddy-naive;
    settings = {
      apps = {
        http = {
          servers = {
            srv0 = {
              listen = [ ":443" ];
              routes = [
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
