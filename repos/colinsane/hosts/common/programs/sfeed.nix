# simple RSS and Atom parser
# - <https://codemadness.org/sfeed-simple-feed-parser.html>
# - man 5 sfeedrc
#
# call `sfeed_update` to query each feed and populate entries in ~/.sfeed/feeds
{ lib, config, sane-lib, ... }:
let
  feeds = sane-lib.feeds;
  allFeeds = config.sane.feeds;
  wantedFeeds = feeds.filterByFormat ["text"] allFeeds;
  sfeedEntries = builtins.map (feed:
    # format:
    # feed <name> <feedurl> [basesiteurl] [encoding]
    lib.escapeShellArgs [ "feed" (if feed.title != null then feed.title else feed.url) feed.url ]
  ) wantedFeeds;
in {
  sane.programs.sfeed = {
    sandbox.net = "clearnet";

    fs.".sfeed/sfeedrc".symlink.text = ''
      feeds() {
        ${lib.concatStringsSep "\n  " sfeedEntries}
      }
    '';

    # this is where the parsed feed items go
    persist.byStore.plaintext = [ ".sfeed/feeds" ];
  };
}
