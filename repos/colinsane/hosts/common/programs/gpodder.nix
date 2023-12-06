# help:
# - #gpodder on irc.libera.chat
{ config, pkgs, sane-lib, ... }:

let
  feeds = sane-lib.feeds;
  all-feeds = config.sane.feeds;
  wanted-feeds = feeds.filterByFormat [ "podcast" "video" ] all-feeds;
in {
  sane.programs.gpodder = {
    package = pkgs.gpodder-adaptive-configured.overrideAttrs (base: {
      # environment variables:
      # - GPODDER_HOME (defaults to "~/gPodder")
      # - GPODDER_DOWNLOAD_DIR (defaults to "$GPODDER_HOME/Downloads")
      # - GPODDER_WRITE_LOGS ("yes" or "no")
      # - GPODDER_EXTENSIONS
      # - GPODDER_DISABLE_EXTENSIONS ("yes" or "no")
      extraMakeWrapperArgs = (base.extraMakeWrapperArgs or []) ++ [
        "--set" "GPODDER_HOME" "~/.local/share/gPodder"
      ];
    });
    # package = pkgs.gpodder-configured;
    fs.".config/gpodderFeeds.opml".symlink.text = feeds.feedsToOpml wanted-feeds;

    # XXX: we preserve the whole thing because if we only preserve gPodder/Downloads
    #   then startup is SLOW during feed import, and we might end up with zombie eps in the dl dir.
    persist.byStore.plaintext = [ ".local/share/gPodder" ];
  };
}
