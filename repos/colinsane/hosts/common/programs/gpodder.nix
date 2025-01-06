# help:
# - #gpodder on irc.libera.chat
{ config, pkgs, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  all-feeds = config.sane.feeds;
  wanted-feeds = feeds.filterByFormat [ "podcast" "video" ] all-feeds;
in {
  sane.programs.gpodder = {
    packageUnwrapped = (pkgs.gpodder-configured.override {
      gpodder = pkgs.gpodder-adaptive;
    }).overrideAttrs (base: {
      # environment variables:
      # - GPODDER_HOME (defaults to "~/gPodder")
      # - GPODDER_DOWNLOAD_DIR (defaults to "$GPODDER_HOME/Downloads")
      # - GPODDER_WRITE_LOGS ("yes" or "no")
      # - GPODDER_EXTENSIONS
      # - GPODDER_DISABLE_EXTENSIONS ("yes" or "no")
      extraMakeWrapperArgs = (base.extraMakeWrapperArgs or []) ++ [
        "--set" "GPODDER_HOME" "~/.local/share/gPodder"
        # place downloads in a shared media directory to ensure sandboxed apps can read them
        "--set" "GPODDER_DOWNLOAD_DIR" "~/Videos/gPodder"
      ];
    });

    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # it won't launch without it, dunno exactly why.
    sandbox.whitelistDri = true;  #< hopefully slightly more bearable speed
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";

    fs.".config/gpodderFeeds.opml".symlink.text = feeds.feedsToOpml wanted-feeds;

    persist.byStore.plaintext = [
      "Videos/gPodder"
      # if you don't persist its database, you get untracked (and hence non-gc'd) downloads, plus slooow startup.
      ".local/share/gPodder"
    ];
  };
}
