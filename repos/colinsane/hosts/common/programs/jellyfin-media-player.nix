{ pkgs, ... }:

{
  sane.programs.jellyfin-media-player = {
    package = pkgs.jellyfin-media-player;
    # package = pkgs.jellyfin-media-player-qt6;

    # jellyfin stores things in a bunch of directories: this one persists auth info.
    # it *might* be possible to populate this externally (it's Qt stuff), but likely to
    # be fragile and take an hour+ to figure out.
    persist.plaintext = [ ".local/share/Jellyfin Media Player" ];
  };
}
