{ pkgs, ... }:
{
  sane.programs.tor-browser-bundle-bin = {
    package = pkgs.tor-browser-bundle-bin.override {
      # hardenedMalloc solves an "unable to connect to Tor" error when pressing the "connect" button
      # - still required as of 2023/07/14
      useHardenedMalloc = false;
    };
    persist.byStore.cryptClearOnBoot = [
      ".local/share/tor-browser"
    ];
  };
}
