{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mbtileserver;
in
{
  options.services.mbtileserver = {
    enable = mkEnableOption "mbtileserver";
  };

  config = mkIf cfg.enable {
    systemd.services.mbtileserver = {
      description = "MBTiles server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment.TILE_DIR = "/srv/tilesets";
      serviceConfig = {
        DynamicUser = true;
        LogsDirectory = "mbtileserver";
        ExecStart = "${pkgs.mbtileserver}/bin/mbtileserver --enable-reload-signal --tiles-only";
        Restart = "always";
      };
    };
  };
}
