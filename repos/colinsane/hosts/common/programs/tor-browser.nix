{ pkgs, ... }:
{
  sane.programs.tor-browser = {
    packageUnwrapped = pkgs.tor-browser.overrideAttrs (upstream: {
      # add `--allow-remote` flag so that i can do `tor-browser http://...` to open in an existing instance.
      preBuild = (upstream.preBuild or "") + ''
        makeWrapper() {
          makeShellWrapper "$@" --add-flags --allow-remote
        }
      '';
    });
    sandbox.net = "clearnet";  # tor over VPN wouldn't make sense
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user.own = [ "org.mozilla.firefox.*" ];  # so that `tor-browser http://...` can open using an existing instance
    sandbox.whitelistPortal = [
      "FileChooser"
      "OpenURI"
    ];
    sandbox.whitelistWayland = true;
    # sandbox.mesaCacheDir = ".cache/tor-browser/mesa";  # don't persist mesa dir (privacy)
    persist.byStore.ephemeral = [
      ".local/share/tor-browser"  # persisted because of downloads, i think??
    ];
    mime.urlAssociations."^https?://.+\.onion$" = "torbrowser.desktop";
  };
}
