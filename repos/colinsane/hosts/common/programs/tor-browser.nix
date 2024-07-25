{ pkgs, ... }:
{
  sane.programs.tor-browser = {
    # packageUnwrapped = pkgs.tor-browser.override {
    #   # hardenedMalloc solves an "unable to connect to Tor" error when pressing the "connect" button
    #   # - required as recently as 2023/07/14
    #   # - no longer required as of 2024/01/27
    #   useHardenedMalloc = false;
    # };
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";  # trivial package, so cheaper to wrap in-place
    sandbox.net = "clearnet";  # tor over VPN wouldn't make sense
    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;
    persist.byStore.ephemeral = [
      ".local/share/tor-browser"
    ];
  };
}
