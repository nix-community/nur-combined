{ config, lib, pkgs, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  all-feeds = config.sane.feeds;
  wanted-feeds = feeds.filterByFormat ["podcast"] all-feeds;
  podcast-urls = lib.concatStringsSep "|" (
    builtins.map (feed: feed.url) wanted-feeds
  );
in
{
  sane.programs.vlc = {
    packageUnwrapped = pkgs.vlc.override {
      # disable uneeded samba features to avoid an expensive samba build
      samba = null;
    };
    sandbox.net = "clearnet";
    sandbox.autodetectCliPaths = "existing";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # mpris
    sandbox.whitelistWayland = true;
    persist.byStore.private = [
      # vlc remembers play position in ~/.config/vlc/vlc-qt-interface.conf
      # filenames are stored in plaintext (unlike mpv, which i think hashes them)
      ({ path = ".config/vlc/vlc-qt-interface.conf"; type = "file"; })
      # vlc caches artwork. i'm not sure where it gets the artwork (internet? embedded metadata?)
      ".cache/vlc"
    ];
    fs.".config/vlc/vlcrc".symlink.text = ''
      [podcast]
      podcast-urls=${podcast-urls}
      [core]
      metadata-network-access=0
      [qt]
      qt-privacy-ask=0
    '';

    mime.associations."audio/flac" = "vlc.desktop";
    mime.associations."audio/mpeg" = "vlc.desktop";
    mime.associations."audio/x-vorbis+ogg" = "vlc.desktop";
    mime.associations."video/mp4" = "vlc.desktop";
    mime.associations."video/quicktime" = "vlc.desktop";
    mime.associations."video/webm" = "vlc.desktop";
    mime.associations."video/x-flv" = "vlc.desktop";
    mime.associations."video/x-matroska" = "vlc.desktop";
  };
}
