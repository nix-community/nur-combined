{
  lib,
  config,
  ...
}:
{

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
                              upstreams = [ { dial = "localhost:5000"; } ];
                            }
                          ];
                        }
                      ];
                    }
                  ];
                  match = [ { host = [ "cache.nyaw.xyz" ]; } ];
                }
                {
                  handle = [

                  ];
                  match = [ { host = [ config.networking.fqdn ]; } ];
                }
                {
                  handle = [
                    {
                      handler = "reverse_proxy";
                      upstreams = [ { dial = "localhost:9000"; } ];
                    }
                  ];
                  match = [ { host = [ "s3.nyaw.xyz" ]; } ];
                }
              ];
              tls_connection_policies = [
                {
                  match = {
                    sni = [
                      "*.nyaw.xyz"
                    ];
                  };
                  certificate_selection = {
                    any_tag = [ "cert0" ];
                  };
                  protocol_min = "tls1.3";
                }
              ];
            };
          };
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
  };
}
