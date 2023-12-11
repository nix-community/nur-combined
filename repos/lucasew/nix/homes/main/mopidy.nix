{ config, lib, pkgs, ...}:

{
  config = lib.mkIf config.services.mopidy.enable {
    services.mopidy.extensionPackages = with pkgs.mopidyPackages; [
      mopidy-mpris
      mopidy-notify
      mopidy-scrobbler
      mopidy-soundcloud
      mopidy-ytmusic
      mopidy-mopify
    ];
  };
}
