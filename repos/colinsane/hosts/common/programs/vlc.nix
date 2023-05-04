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
    # vlc remembers play position in ~/.config/vlc/vlc-qt-interface.conf
    persist.plaintext = [ ".config/vlc" ];
    fs.".config/vlc/vlcrc" = sane-lib.fs.wantedText ''
      [podcast]
      podcast-urls=${podcast-urls}
      [core]
      metadata-network-access=0
      [qt]
      qt-privacy-ask=0
    '';
  };
}
