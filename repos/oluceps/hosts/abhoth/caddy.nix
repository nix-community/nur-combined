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
  repack.caddy = {
    enable = true;
    settings.apps.http.servers = {
      srv0 = {
        routes = [ ];
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
