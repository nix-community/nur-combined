{ lib, config, ... }:
{
  systemd.services.caddy.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];
  repack.caddy = {
    enable = true;
    settings.apps = {
      http.servers.srv0.routes = [
        {
          handle = [
            {
              handler = "subroute";
              routes = [
                {
                  handle = [
                    {
                      handler = "encode";
                      encodings = {
                        zstd = {
                          level = "better";
                        };
                      };
                    }
                    {
                      handler = "reverse_proxy";
                      transport = {
                        protocol = "http";
                        tls = {
                          server_name = "s3.nyaw.xyz";
                        };
                      };
                      upstreams = [ { dial = "10.0.4.2:443"; } ];
                    }
                  ];
                }
              ];
            }
          ];
          match = [ { host = [ "s3.nyaw.xyz" ]; } ];
        }
      ];

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
