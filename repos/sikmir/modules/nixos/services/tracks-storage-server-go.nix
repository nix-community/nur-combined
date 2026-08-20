{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.tracks-storage-server-go;
in
{
  options.services.tracks-storage-server-go = {
    enable = mkEnableOption "tracks-storage-server-go";
    package = mkPackageOption pkgs "tracks-storage-server-go" { };
    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "IP address to listen on.";
    };
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Server port.";
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
      systemd.services.tracks-storage-server-go = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        environment.LISTEN_ADDR = "${cfg.address}:${toString cfg.port}";
        serviceConfig = {
          DynamicUser = true;
          LogsDirectory = "tracks-storage-server-go";
          ExecStart = "${getExe cfg.package}";
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
