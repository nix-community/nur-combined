{
  pkgs,
  lib,
  config,
  ...
}:
{

  systemd.services.caddy.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];

  repack.caddy = {
    enable = true;
    settings = {
      apps = {
        http = {
          servers = {
            srv0 = {
              routes = [
                {
                  handle = [
                    {
                      handler = "reverse_proxy";
                      transport = {
                        protocol = "http";
                        tls = {
                          server_name = "hastur.nyaw.xyz";
                        };
                      };
                      upstreams = [ { dial = "10.0.3.2:443"; } ];
                    }
                  ];
                  match = [ { host = [ "hastur.nyaw.xyz" ]; } ];
                }
                {
                  handle = [
                    {
                      handler = "reverse_proxy";
                      transport = {
                        protocol = "http";
                        tls = {
                          server_name = "kaambl.nyaw.xyz";
                        };
                      };
                      upstreams = [ { dial = "10.0.3.3:443"; } ];
                    }
                  ];
                  match = [ { host = [ "kaambl.nyaw.xyz" ]; } ];
                }
                {
                  handle = [
                    {
                      handler = "reverse_proxy";
                      transport = {
                        protocol = "http";
                        tls = {
                          server_name = "azasos.nyaw.xyz";
                        };
                      };
                      upstreams = [ { dial = "10.0.2.1:443"; } ];
                    }
                  ];
                  match = [ { host = [ "azasos.nyaw.xyz" ]; } ];
                }
              ];
            };
          };
        };
      };
    };
  };
}
