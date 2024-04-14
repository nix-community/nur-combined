# news-flash RSS viewer
# - feeds have to be manually imported:
#   - Local RSS -> Import OPML -> ~/.config/newsflashFeeds.opml
# - clicking article-embedded links doesn't work because of xdg portal stuff
#   - need to either run unsandboxed, or install a org.freedesktop.portal.OpenURI handler
{ config, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  all-feeds = config.sane.feeds;
  # text/image: newsflash renders these natively
  # podcast/video: newsflash dispatches these to xdg-open
  wanted-feeds = feeds.filterByFormat [ "text" "image" "podcast" "video" ] all-feeds;
in {
  sane.programs.newsflash = {
    buildCost = 1;  # mainly for desktop: webkitgtk-6.0
    persist.byStore.plaintext = [ ".local/share/news-flash" ];
    fs.".config/newsflashFeeds.opml".symlink.text =
      feeds.feedsToOpml wanted-feeds
    ;
  };
}
