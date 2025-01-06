# docs:
# - <https://koreader.rocks/user_guide/>
# - <https://github.com/koreader/koreader/wiki>
#
# post-installation setup:
# - add FTP server:
#   - click near top of window
#   - tools icon > Cloud storage
#   - plus icon > FTP server
#     - "Your FTP name": (anything, e.g. "servo books")
#     - FTP address: ftp://servo-hn
#     - FTP username: anonymous
#     - FTP password: (leave empty)
#     - base directory: /media/Books
# - download dictionaries:
#   - search icon > settings > dictionary settings > download dictionaries
#   - these are stored in `~/.config/koreader/data/dict`
# - configure defaults:
#   - edit keys in ~/.config/koreader/settings.reader.lua
#     - default font size: `["copt_font_size"] = 30,`
#     - home dir: `["home_dir"] = "/home/colin/Books",`
{ config, lib, pkgs, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  allFeeds = config.sane.feeds;
  wantedFeeds = feeds.filterByFormat [ "text" ] allFeeds;
  koreaderRssEntries = builtins.map (feed:
    # format:
    # { "<rss/atom url>", limit = <int>, download_full_article=<bool>, include_images=<bool>, enable_filter=<bool>, filter_element = "<css selector>"},
    # limit = 0                    => download and keep *all* articles
    # download_full_article = true => populate feed by downloading the webpage -- not just what's encoded in the RSS <article> tags
    # - use this for articles where the RSS only encodes content previews
    # - in practice, most articles don't work with download_full_article = false
    # enable_filter         = true => only render content that matches the filter_element css selector.
    let fields = [
      (lib.escapeShellArg feed.url)
      "limit = 20"
      "download_full_article = true"
      "include_images = true"
      "enable_filter = false"
      "filter_element = \"\""
    ]; in "{ ${lib.concatStringsSep ", " fields } }"
  ) wantedFeeds;
in {
  sane.programs.koreader = {
    packageUnwrapped = pkgs.koreader-from-src;
    sandbox.net = "clearnet";
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # for opening the web browser via portal
    sandbox.whitelistDri = true;  # reduces startup time and subjective page flip time
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Books/Books"
      "Books/local"
      "Books/servo"
    ];

    # koreader applies these lua "patches" at boot:
    # - <https://github.com/koreader/koreader/wiki/User-patches>
    # the naming is IMPORTANT. these must start with a `2-` in order to be invoked during the right initialization phase
    #
    # 2023/10/29: koreader code hasn't changed, but somehow FTP browser seems usable even without the isConnected patch now.
    # fs.".config/koreader/patches/2-colin-NetworkManager-isConnected.lua".symlink.target = "${./2-colin-NetworkManager-isConnected.lua}";

    fs.".config/koreader/patches/2-02-colin-impl-clipboard-ops.lua".symlink.target = "${./2-02-colin-impl-clipboard-ops.lua}";

    # koreader news plugin, enabled by default. file format described here:
    # - <repo:koreader/koreader:plugins/newsdownloader.koplugin/feed_config.lua>
    fs.".config/koreader/news/feed_config.lua".symlink.text = ''
      return {--do NOT change this line
        ${lib.concatStringsSep ",\n  " koreaderRssEntries}
      }--do NOT change this line
    '';
    # easier to navigate via filebrowser than finding the news menu entry
    fs."Books/rss-koreader".symlink.target = "../.config/koreader/news";

    # koreader on aarch64 errors if there's no fonts directory (sandboxing thing, i guess)
    fs.".local/share/fonts".dir = {};

    # history, cache, dictionaries...
    # could be more explicit if i symlinked the history.lua file to somewhere it can persist better.
    persist.byStore.plaintext = [ ".config/koreader" ];
  };
}
