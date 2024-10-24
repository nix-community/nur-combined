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
              routes =
                [
                ];
              tls_connection_policies = [
                {
                  match = {
                    sni = [ "kaambl.nyaw.xyz" ];
                  };
                  certificate_selection = {
                    any_tag = [ "cert0" ];
                  };
                }
              ];
            };
          };
        };
        tls.certificates.load_files = [
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
