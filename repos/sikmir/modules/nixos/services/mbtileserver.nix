{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.mbtileserver;
in
{
  options.services.mbtileserver = {
    enable = mkEnableOption "mbtileserver";
    package = mkOption {
      type = types.package;
      default = pkgs.mbtileserver;
      defaultText = literalMD "pkgs.mbtileserver";
      description = "Which mbtileserver package to use.";
    };
    tileDir = mkOption {
      type = types.path;
      default = "/srv/tilesets";
      description = "The path where *.mbtiles files stored.";
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
      systemd.services.mbtileserver = {
        description = "MBTiles server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        environment.TILE_DIR = cfg.tileDir;
        serviceConfig = {
          DynamicUser = true;
          LogsDirectory = "mbtileserver";
          ExecStart = "${lib.getBin cfg.package}/bin/mbtileserver --enable-reload-signal --tiles-only";
          Restart = "always";
        };
      };
    }
    (mkIf cfg.nginx.enable {
      services.nginx = {
        enable = true;
        virtualHosts."${cfg.nginx.hostName}" = {
          locations."/" = {
            root = cfg.tileDir;
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
            '';
          };
          locations."/services" = {
            proxyPass = "http://localhost:8000";
            extraConfig = ''
              #proxy_set_header Host ''$host;
              #proxy_set_header X-Forwarded-Host ''$server_name;
              #proxy_set_header X-Real-IP ''$remote_addr;
              add_header Cache-Control 'public, max-age=3600, must-revalidate';
            '';
          };
        };
      };
    })
  ]);
}
