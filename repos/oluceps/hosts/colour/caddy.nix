{ lib, config, ... }:
{

  systemd.services.caddy.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];

  repack.caddy = {
    enable = true;
    settings = {
      apps = {
        http.grace_period = "1s";
        http = {
          servers = {
            srv0 = {
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
                              upstreams = [ { dial = "10.0.1.3:7001"; } ];
                            }
                          ];
                        }
                      ];
                    }
                  ];
                  match = [ { host = [ "dokidoki.nyaw.xyz" ]; } ];
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
                              upstreams = [ { dial = "10.0.1.3:7000"; } ];
                            }
                          ];
                        }
                      ];
                    }
                  ];
                  match = [ { host = [ "api.heartrate.nyaw.xyz" ]; } ];
                  terminal = true;
                }

                # {
                #   handle = [{
                #     handler = "subroute";
                #     routes = [{
                #       handle = [{
                #         handler = "reverse_proxy";
                #         upstreams = [{
                #           dial = "10.0.2.2:3001";
                #         }];
                #       }];
                #     }];
                #   }];
                #   match = [{
                #     host = [ "chat.nyaw.xyz" ];
                #   }];
                #   terminal = true;
                # }

                # {
                #   handle = [{
                #     handler = "subroute";
                #     routes = [{
                #       handle = [{
                #         handler = "reverse_proxy";
                #         upstreams = [{
                #           dial = "10.0.2.2:8888";
                #         }];
                #       }];
                #     }];
                #   }];
                #   match = [{
                #     host = [ "api.atuin.nyaw.xyz" ];
                #   }];
                #   terminal = true;
                # }
              ];
            };
          };
        };
      };
    };
  };
}
