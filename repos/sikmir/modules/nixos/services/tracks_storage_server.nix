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
    nginx = mkOption {
      default = { };
      description = ''
        Configuration for nginx reverse proxy.
      '';
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Configure the nginx reverse proxy settings.
            '';
          };
          hostName = mkOption {
            type = types.str;
            description = ''
              The hostname use to setup the virtualhost configuration
            '';
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
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
    }
    (mkIf cfg.nginx.enable {
      services.nginx = {
        enable = true;
        virtualHosts."${cfg.nginx.hostName}" = {
          locations."/" = {
            extraConfig = ''
              uwsgi_pass localhost:8181;
              include ${config.services.nginx.package}/conf/uwsgi_params;

              more_clear_headers Access-Control-Allow-Origin;
              more_clear_headers Access-Control-Allow-Credentials;
              more_set_headers 'Access-Control-Allow-Origin: $http_origin';
              more_set_headers 'Access-Control-Allow-Credentials: true';
              more_set_headers 'Cache-Control: max-age=315360000';
              more_set_headers 'Expires: Thu, 31 Dec 2037 23:55:55 GMT';
              more_set_headers 'Vary: Origin';
            '';
          };
        };
      };
    })
  ]);
}
