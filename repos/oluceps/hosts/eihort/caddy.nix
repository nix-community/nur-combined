{
  pkgs,
  lib,
  config,
  ...
}:
{
  repack.reuse-cert.enable = false;
  systemd.services.caddy.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];
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
                        upstreams = [ { dial = "localhost:9000"; } ];
                      }
                    ];
                    match = [ { host = [ "s3.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:2283"; } ];
                      }
                    ];
                    match = [ { host = [ "photo.nyaw.xyz" ]; } ];
                  }
                  {
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [ { dial = "localhost:9001"; } ];
                        rewrite.strip_path_prefix = "/minio";
                      }
                    ];
                    match = [
                      {
                        host = [ "eihort.nyaw.xyz" ];
                        path = [ "/minio/*" ];
                      }
                    ];
                  }
                  (import ../caddy-matrix.nix {
                    inherit pkgs;
                    matrix-upstream = "localhost:6167";
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
                upstreams = [ { dial = "unix//run/misskey/rw.sock"; } ];
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
