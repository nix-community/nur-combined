{ lib, config, ... }:
{

  repack.caddy = {
    enable = true;
    settings.apps.http.servers.srv0.routes = [
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
                  {
                    match = [
                      {
                        host = [ "matrix.nyaw.xyz" ];
                        path = [ "/_matrix/*" ];
                      }
                    ];
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "10.0.4.2:6167"; } ];
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
        match = [ { host = [ "s3.nyaw.xyz" ]; } ];
      }
    ];
  };
}
