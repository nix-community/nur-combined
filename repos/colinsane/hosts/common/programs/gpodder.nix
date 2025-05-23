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
        # "--run" "export GPODDER_HOME=~/.local/share/gPodder"  #< unquote `~/.local/share/gPodder` to force run-time home expansion
        # place downloads in a shared media directory to ensure sandboxed apps can read them
        "--set" "GPODDER_DOWNLOAD_DIR" "~/Videos/gPodder"
        # "--run" "export GPODDER_DOWNLOAD_DIR=~/Videos/gPodder"
      ];
    });

    sandbox.whitelistDbus.user.own = [ "org.gpodder" "org.gpodder.gpodder" ];
    sandbox.whitelistDri = true;  #< makes the UI way more responsive
    sandbox.whitelistPortal = [
      "OpenURI"
    ];
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";

    fs.".config/gpodderFeeds.opml".symlink.text = feeds.feedsToOpml wanted-feeds;

    services.gpodder-ensure-feeds = {
      description = "synchronize static OPML feeds into gPodder's subscription database";
      partOf = [ "default" ];
      startCommand = ''gpodder-ensure-feeds ''${HOME}/.config/gpodderFeeds.opml'';
    };

    persist.byStore.plaintext = [
      "Videos/gPodder"
      # if you don't persist its database, you get untracked (and hence non-gc'd) downloads, plus slooow startup.
      ".local/share/gPodder"
    ];
  };
}
