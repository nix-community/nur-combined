{ config, lib, pkgs, ...}:

{
  config = lib.mkIf config.services.mopidy.enable {
    home.packages = [ pkgs.ncmpcpp ];
    services.mopidy = {
      settings = {
      #   mopify = {
      #     enabled = true;
      #     debug = false;
      #   };
        mpd = {
          hostname = "::";
        };
        mpris = {
          enabled = true;
        };
      };
      extensionPackages = with pkgs.mopidyPackages; [
        mopidy-mpd
        mopidy-mpris
        mopidy-notify
        mopidy-scrobbler
        mopidy-soundcloud
        mopidy-ytmusic
        mopidy-mopify
      ];
    };
  };
}
