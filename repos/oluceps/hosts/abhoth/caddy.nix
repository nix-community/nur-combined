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
    settings.apps.http.servers.srv0.routes = [ ];
  };
}
