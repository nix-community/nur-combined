{ lib, config, ... }:
{

  systemd.services.nginx.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];

  srv.nginx.enable = true;
}
