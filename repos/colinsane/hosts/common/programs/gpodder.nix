# gnome feeds RSS viewer
{ config, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  all-feeds = config.sane.feeds;
  wanted-feeds = feeds.filterByFormat ["podcast"] all-feeds;
in {
  sane.programs.gpodder.fs.".config/gpodderFeeds.opml" = sane-lib.fs.wantedText (
    feeds.feedsToOpml wanted-feeds
  );
}
