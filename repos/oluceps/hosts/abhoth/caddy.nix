{
  pkgs,
  lib,
  config,
  ...
}:
{

  repack.caddy = {
    enable = true;
    settings.apps.http.servers.srv0.routes = [ ];
  };
}
