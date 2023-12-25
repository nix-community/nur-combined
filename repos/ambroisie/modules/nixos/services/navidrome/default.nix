# A FLOSS self-hosted, subsonic compatible music server
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.navidrome;
in
{
  options.my.services.navidrome = with lib; {
    enable = mkEnableOption "Navidrome Music Server";

    settings = mkOption {
      type = (pkgs.formats.json { }).type;
      default = { };
      example = {
        "LastFM.ApiKey" = "MYKEY";
        "LastFM.Secret" = "MYSECRET";
        "Spotify.ID" = "MYKEY";
        "Spotify.Secret" = "MYSECRET";
      };
      description = ''
        Additional settings.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 4533;
      example = 8080;
      description = "Internal port for webui";
    };

    musicFolder = mkOption {
      type = types.str;
      example = "/mnt/music/";
      description = "Music folder";
    };
  };

  config = lib.mkIf cfg.enable {
    services.navidrome = {
      enable = true;

      settings = cfg.settings // {
        Port = cfg.port;
        Address = "127.0.0.1"; # Behind reverse proxy, so only loopback
        MusicFolder = cfg.musicFolder;
        LogLevel = "info";
      };
    };

    my.services.nginx.virtualHosts = {
      music = {
        inherit (cfg) port;
      };
    };
  };
}
