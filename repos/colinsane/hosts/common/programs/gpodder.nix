# gnome feeds RSS viewer
{ config, pkgs, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  all-feeds = config.sane.feeds;
  wanted-feeds = feeds.filterByFormat ["podcast"] all-feeds;
in {
  sane.programs.gpodder = {
    package = pkgs.gpodder-adaptive-configured;
    # package = pkgs.gpodder-configured;
    fs.".config/gpodderFeeds.opml".symlink.text = feeds.feedsToOpml wanted-feeds;

    # XXX: we preserve the whole thing because if we only preserve gPodder/Downloads
    #   then startup is SLOW during feed import, and we might end up with zombie eps in the dl dir.
    persist.plaintext = [ "gPodder" ];
  };
}
