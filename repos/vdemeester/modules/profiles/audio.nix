{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.audio;
in
{
  options = {
    profiles.audio = {
      enable = mkEnableOption "Enable audio profile";
      shairport-sync = mkEnableOption "Enable shairport-sync";
      mpd = {
        enable = mkEnableOption "Enable mpd";
        musicDir = mkOption {
          description = "Data where to find the music for mpd";
          type = types.str;
        };
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      services.shairport-sync.enable = cfg.shairport-sync;
    }
    (
      mkIf cfg.mpd.enable {
        services.mpd = {
          enable = true;
          musicDirectory = cfg.mpd.musicDir;
          network.listenAddress = "any";
          extraConfig = ''
            audio_output {
              type    "pulse"
              name    "Local MPD"
            }
          '';
        };
        services.mpdris2 = {
          enable = true;
          mpd.host = "127.0.0.1";
        };
        home.packages = with pkgs; [
          mpc_cli
          ncmpcpp
        ];
      }
    )
    (
      mkIf (cfg.mpd.enable && config.profiles.desktop.enable) {
        home.packages = with pkgs; [
          ario
        ];
      }
    )
  ]);
}
