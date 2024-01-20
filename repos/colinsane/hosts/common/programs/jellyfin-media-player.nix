{ pkgs, ... }:

{
  sane.programs.jellyfin-media-player = {
    # packageUnwrapped = pkgs.jellyfin-media-player;
    # qt6 version is slightly buggy, but also most qtwebengine apps (e.g. zeal) are on qt5
    #   so using qt6 would force yet *another* qtwebengine compile.
    # packageUnwrapped = pkgs.jellyfin-media-player-qt6;

    # jellyfin stores things in a bunch of directories: this one persists auth info.
    # it *might* be possible to populate this externally (it's Qt stuff), but likely to
    # be fragile and take an hour+ to figure out.
    persist.byStore.plaintext = [ ".local/share/Jellyfin Media Player" ];
  };
}
