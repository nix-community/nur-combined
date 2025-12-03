# N.B.: to disable scripts, do one of:
# a. open `about:config` and set `browser.security_level.security_slider=2`
# b. use the security slider in "configure connection"
# unfortunately, both of these routes require the browser to be restarted (as they advise),
# else javascript is silently left enabled.

{ pkgs, ... }:
{
  sane.programs.tor-browser = {
    packageUnwrapped = pkgs.tor-browser.overrideAttrs (upstream: {
      # add `--allow-remote` flag so that i can do `tor-browser http://...` to open in an existing instance.
      preBuild = (upstream.preBuild or "") + ''
        makeWrapper() {
          makeShellWrapper "$@" --add-flag --allow-remote
        }
      '';
    });
    sandbox.net = "clearnet";  # tor over VPN wouldn't make sense
    sandbox.whitelistAudio = true;
    # sandbox.whitelistDbus.user.own = [ "org.mozilla.firefox.*" ];  # so that `tor-browser http://...` can open using an existing instance
    sandbox.whitelistPortal = [
      "FileChooser"
      # "OpenURI"
    ];
    sandbox.whitelistWayland = true;
    # sandbox.mesaCacheDir = ".cache/tor-browser/mesa";  # don't persist mesa dir (privacy)
    persist.byStore.ephemeral = [
      ".local/share/tor-browser"  # persisted because of downloads, i think??
      #v to persist $profile/prefs.js, required for js toggle. TODO: persist this more narrowly
      ".tor project/firefox"
    ];
    mime.urlAssociations."^https?://.+\.onion$" = "torbrowser.desktop";
  };
}
