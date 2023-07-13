{ config, lib, sane-lib, ... }:

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
    persist.private = [
      # vlc remembers play position in ~/.config/vlc/vlc-qt-interface.conf
      # filenames are stored in plaintext (unlike mpv, which i think hashes them)
      ".config/vlc"
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
  };
}
