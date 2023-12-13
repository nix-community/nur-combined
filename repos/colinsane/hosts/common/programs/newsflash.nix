# news-flash RSS viewer
{ config, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  all-feeds = config.sane.feeds;
  wanted-feeds = feeds.filterByFormat ["text" "image"] all-feeds;
in {
  sane.programs.newsflash = {
    slowToBuild = true;  # mainly for desktop: webkitgtk-6.0
    persist.byStore.plaintext = [ ".local/share/news-flash" ];
    fs.".config/newsflashFeeds.opml".symlink.text =
      feeds.feedsToOpml wanted-feeds
    ;
  };
}
