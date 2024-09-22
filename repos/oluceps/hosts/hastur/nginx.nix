{ lib, config, ... }:
{

  systemd.services.nginx.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];

  repack.nginx.enable = true;
}
