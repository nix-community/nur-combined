{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.firefox.config;
in
{
  sane.programs.firefox = {
    config.addons = {
      # fxCast = {
      #   # add a menu to cast to chromecast devices, but it doesn't seem to work very well.
      #   # right click (or shift+rc) a video, then select "cast".
      #   # - asciinema.org: icon appears, but glitches when clicked.
      #   # - youtube.com: no icon appears, even when site is whitelisted.
      #   # future: maybe better to have browser open all videos in mpv, and then use mpv for casting.
      #   # see e.g. `ff2mpv`, `open-in-mpv` (both are packaged in nixpkgs)
      #   package = pkgs.firefox-extensions.fx_cast;
      #   nativeMessagingHosts = [ pkgs.fx-cast-bridge ];
      #   enable = lib.mkDefault false;
      # };
      archive-page = {
        enable = lib.mkDefault true;
      };
      browserpass-extension = {
        nativeMessagingHosts = [ "browserpass" ];
        enable = lib.mkDefault true;
      };
      bypass-paywalls-clean = {
        enable = lib.mkDefault false;
      };
      # ctrl-shift-c-should-copy = {
      #   package = pkgs.firefox-extensions.ctrl-shift-c-should-copy;
      #   enable = lib.mkDefault false;  # prefer patching firefox source code, so it works in more places
      # };
      default-zoom = {
        enable = lib.mkDefault true;
      };
      # ether-metamask = {
      #   enable = lib.mkDefault false;  # until i can disable the first-run notification
      # };
      firefox-xdg-open = {
        # test: `xdg-open xdg-open:https://uninsane.org`
        suggestedPrograms = [ "firefox-xdg-open" ];
        enable = lib.mkDefault true;
      };
      # i2p-in-private-browsing = {
      #   enable = lib.mkDefault config.services.i2p.enable;
      # };
      i-still-dont-care-about-cookies = {
        enable = lib.mkDefault false;  #< obsoleted by uBlock Origin annoyances/cookies lists
      };
      kagi-search = {
        enable = lib.mkDefault true;
      };
      # open-in-mpv = {
      #   # test: `open-in-mpv 'mpv:///open?url=https://www.youtube.com/watch?v=dQw4w9WgXcQ'`
      #   package = pkgs.firefox-extensions.open-in-mpv;
      #   nativeMessagingHosts = [ "open-in-mpv" ];
      #   enable = lib.mkDefault false;
      # };
      passff = {
        nativeMessagingHosts = [ "passff-host" ];
        enable = lib.mkDefault false;
      };
      sidebery = {
        enable = lib.mkDefault false; # firefox 133+ has native vertical tabs (about:config `sidebar.*`)
      };
      sponsorblock = {
        enable = lib.mkDefault true;
      };
      ublacklist = {
        enable = lib.mkDefault false;
      };
      ublock-origin = {
        enable = lib.mkDefault true;
      };
    };

    # uBlock configuration:
    fs.".mozilla/managed-storage/uBlock0@raymondhill.net.json".symlink.target = cfg.addons.ublock-origin.package.makeConfig {
      # more filter lists are available here:
      # - <https://easylist.to>
      #   - <https://github.com/easylist/easylist.git>
      # - <https://github.com/yokoffing/filterlists>
      filterFiles = let
        getUasset = n: "${pkgs.uassets}/share/filters/${n}.txt";
      in [
        # default ublock filters:
        (getUasset "ublock-filters")
        (getUasset "ublock-badware")
        (getUasset "ublock-privacy")
        (getUasset "ublock-quick-fixes")
        (getUasset "ublock-unbreak")
        (getUasset "easylist")
        (getUasset "easyprivacy")
        # (getUasset "urlhaus-1")  #< TODO: i think this is the same as urlhaus-filter-online
        (getUasset "urlhaus-filter-online")
        # (getUasset "plowe-0")   #< TODO: where does this come from?
        # (getUasset "ublock-cookies-adguard")  #< TODO: where does this come from?
        # filters i've added:
        (getUasset "easylist-annoyances")  #< blocks in-page popups, "social media content" (e.g. FB like button; improves loading time)
        (getUasset "easylist-cookies")  #< blocks GDPR cookie consent popovers (e.g. at stackoverflow.com)
        # (getUasset "ublock-annoyances-others")
        # (getUasset "ublock-annoyances-cookies")
      ];
    };

    fs.".mozilla/managed-storage/default-zoom@uninsane.org.json".symlink.text = ''
      {
        "name": "default-zoom@uninsane.org",
        "description": "ignored",
        "type": "storage",
        "data": {
          "formFactor": "${cfg.formFactor}"
        }
      }
    '';
  };
}
