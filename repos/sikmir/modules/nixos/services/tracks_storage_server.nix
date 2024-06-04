{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.tracks_storage_server;
in
{
  options.services.tracks_storage_server = {
    enable = mkEnableOption "tracks_storage_server";
    package = mkPackageOption pkgs "tracks_storage_server" { };
  };

  config = mkIf cfg.enable {
    services.uwsgi.enable = true;
    services.uwsgi.plugins = [ "python3" ];
    services.uwsgi.instance = {
      type = "emperor";
      vassals.tracks = {
        type = "normal";
        master = true;
        workers = 2;
        socket = "127.0.0.1:8181";
        module = "server:application";
        pythonPackages = self: [ cfg.package ];
      };
    };
  };
}
