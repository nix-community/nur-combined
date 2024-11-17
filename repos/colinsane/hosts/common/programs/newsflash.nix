# news-flash RSS viewer  (exe: `io.gitlab.news_flash.NewsFlash`)
# - feeds have to be manually imported:
#   - Local RSS -> Import OPML -> ~/.config/newsflashFeeds.opml
#     option may be greyed out on first run: just restart it.
#     takes about 20 minutes to import results from scratch.
# TODO: auto-import feeds
# - `newsflash -s` might allow importing individual feeds; not removing them, though
{ config, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  all-feeds = config.sane.feeds;
  # text/image: newsflash renders these natively
  # podcast/video: newsflash dispatches these to xdg-open
  wanted-feeds = feeds.filterByFormat [ "text" "image" "podcast" "video" ] all-feeds;
in {
  sane.programs.newsflash = {
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;  #< for embedded videos
    sandbox.whitelistDbus = [ "user" ];
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      # the app sandboxes itself with bwrap, which needs these.
      #   but it actually only cares that /sys/{block,bus,class/block} *exist*: it doesn't care if there's anything in them.
      #   so bind empty (sub)directories
      "/sys/block/loop7"
      "/sys/bus/container/devices"
      "/sys/class/block/loop7"
    ];

    buildCost = 2;  # mainly for desktop: webkitgtk-6.0
    persist.byStore.plaintext = [
      ".local/share/news-flash" #< sqlite database, the actually important stuff
      # ".local/share/news_flash"  #< device IDs (?)
      ".config/news-flash"  #< includes `"backend": "local_rss"`
    ];
    persist.byStore.ephemeral = [
      ".cache/news_flash"  #< WebKit cache
    ];
    #v for *manual* use:
    fs.".config/newsflashFeeds.opml".symlink.text =
      feeds.feedsToOpml wanted-feeds
    ;
  };
}
