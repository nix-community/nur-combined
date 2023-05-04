# gnome feeds RSS viewer
{ config, lib, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  all-feeds = config.sane.feeds;
  wanted-feeds = feeds.filterByFormat ["text" "image"] all-feeds;
in {
  sane.programs.gnome-feeds.fs.".config/org.gabmus.gfeeds.json" = sane-lib.fs.wantedText (
    builtins.toJSON {
      # feed format is a map from URL to a dict,
      #   with dict["tags"] a list of string tags.
      feeds = sane-lib.mapToAttrs (feed: {
        name = feed.url;
        value.tags = [ feed.cat feed.freq ];
      }) wanted-feeds;
      dark_reader = false;
      new_first = true;
      # windowsize = {
      #   width = 350;
      #   height = 650;
      # };
      max_article_age_days = 90;
      enable_js = false;
      max_refresh_threads = 3;
      # saved_items = {};
      # read_items = [];
      show_read_items = true;
      full_article_title = true;
      # views: "webview", "reader", "rsscont"
      default_view = "rsscont";
      open_links_externally = true;
      full_feed_name = false;
      refresh_on_startup = true;
      tags = lib.unique (
        (builtins.catAttrs "cat" wanted-feeds) ++ (builtins.catAttrs "freq" wanted-feeds)
      );
      open_youtube_externally = false;
      media_player = "vlc";  # default: mpv
    }
  );
}
