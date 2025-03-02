{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.elevation-server;
in
{
  options.services.elevation-server = {
    enable = mkEnableOption "elevation-server";
    package = mkPackageOption pkgs "elevation-server" { };
    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address to bind to.";
    };
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen.";
    };
    threads = mkOption {
      type = types.int;
      default = 10;
      description = "Maximum number of concurrently served requests.";
    };
    demTiles = mkOption {
      type = types.path;
      default = "/srv/tilesets/dem_tiles";
      description = "The path to file with elevation tile.";
    };
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
      systemd.services.elevation-server = {
        description = "Elevation server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          DynamicUser = true;
          LogsDirectory = "elevation-server";
          ExecStart = "${getBin cfg.package}/bin/elevation_server -dem ${cfg.demTiles} -host ${cfg.address} -port ${toString cfg.port} -threads ${toString cfg.threads}";
          Restart = "always";
        };
      };
    }
    (mkIf cfg.nginx.enable {
      services.nginx = {
        enable = true;
        virtualHosts."${cfg.nginx.hostName}" = {
          locations."/" = {
            proxyPass = "http://${cfg.address}:${toString cfg.port}";
            extraConfig = ''
              more_clear_headers Access-Control-Allow-Origin;
              more_clear_headers Access-Control-Allow-Credentials;
              more_set_headers 'Access-Control-Allow-Origin: $http_origin';
              more_set_headers 'Access-Control-Allow-Credentials: true';
              more_set_headers 'Cache-Control: max-age=86400';
              more_set_headers 'Vary: Origin';
            '';
          };
        };
      };
    })
  ]);
}
