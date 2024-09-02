{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.firefox.config;
in
{
  sane.programs.firefox = {
    config.addons = {
      fxCast = {
        # add a menu to cast to chromecast devices, but it doesn't seem to work very well.
        # right click (or shift+rc) a video, then select "cast".
        # - asciinema.org: icon appears, but glitches when clicked.
        # - youtube.com: no icon appears, even when site is whitelisted.
        # future: maybe better to have browser open all videos in mpv, and then use mpv for casting.
        # see e.g. `ff2mpv`, `open-in-mpv` (both are packaged in nixpkgs)
        package = pkgs.firefox-extensions.fx_cast;
        enable = lib.mkDefault false;
      };
      browserpass-extension = {
        package = pkgs.firefox-extensions.browserpass-extension;
        enable = lib.mkDefault true;
      };
      bypass-paywalls-clean = {
        package = pkgs.firefox-extensions.bypass-paywalls-clean;
        enable = lib.mkDefault true;
      };
      ctrl-shift-c-should-copy = {
        package = pkgs.firefox-extensions.ctrl-shift-c-should-copy;
        enable = lib.mkDefault false;  # prefer patching firefox source code, so it works in more places
      };
      ether-metamask = {
        package = pkgs.firefox-extensions.ether-metamask;
        enable = lib.mkDefault false;  # until i can disable the first-run notification
      };
      firefox-xdg-open = {
        # test: `xdg-open xdg-open:https://uninsane.org`
        package = pkgs.firefox-extensions.firefox-xdg-open;
        enable = lib.mkDefault true;
      };
      i2p-in-private-browsing = {
        package = pkgs.firefox-extensions.i2p-in-private-browsing;
        enable = lib.mkDefault config.services.i2p.enable;
      };
      i-still-dont-care-about-cookies = {
        package = pkgs.firefox-extensions.i-still-dont-care-about-cookies;
        enable = lib.mkDefault false;  #< obsoleted by uBlock Origin annoyances/cookies lists
      };
      open-in-mpv = {
        # test: `open-in-mpv 'mpv:///open?url=https://www.youtube.com/watch?v=dQw4w9WgXcQ'`
        package = pkgs.firefox-extensions.open-in-mpv;
        enable = lib.mkDefault false;
      };
      sidebery = {
        package = pkgs.firefox-extensions.sidebery;
        enable = lib.mkDefault true;
      };
      sponsorblock = {
        package = pkgs.firefox-extensions.sponsorblock;
        enable = lib.mkDefault true;
      };
      ublacklist = {
        package = pkgs.firefox-extensions.ublacklist;
        enable = lib.mkDefault false;
      };
      ublock-origin = {
        package = pkgs.firefox-extensions.ublock-origin;
        enable = lib.mkDefault true;
      };
    };

    suggestedPrograms = lib.optionals cfg.addons.firefox-xdg-open.enable [
      "firefox-xdg-open"
    ] ++ lib.optionals cfg.addons.open-in-mpv.enable [
      "open-in-mpv"
    ];

    sandbox.extraHomePaths = lib.optionals cfg.addons.browserpass-extension.enable [
      # browserpass needs these paths:
      # - knowledge/secrets/accounts: where the encrypted account secrets live
      # at least one of:
      # - .config/sops: for the sops key which can decrypt account secrets
      # - .ssh: to unlock the sops key, if not unlocked (`sane-secrets-unlock`)
      # TODO: find a way to not expose ~/.ssh to firefox
      # - unlock sops at login (or before firefox launch)?
      # - see if ssh has a more formal type of subkey system?
      # ".ssh/id_ed25519"
      # ".config/sops"
      "knowledge/secrets/accounts"
    ];

    fs.".config/sops".dir = lib.mkIf cfg.addons.browserpass-extension.enable {};  #< needs to be created, not *just* added to the sandbox

    # uBlock configuration:
    fs.".mozilla/firefox/managed-storage/uBlock0@raymondhill.net.json".symlink.target = cfg.addons.ublock-origin.package.makeConfig {
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

    env = lib.mkIf cfg.addons.browserpass-extension.enable {
      # TODO: env.PASSWORD_STORE_DIR only needs to be present within the browser session.
      # alternative to PASSWORD_STORE_DIR:
      # fs.".password-store".symlink.target = lib.mkIf cfg.addons.browserpass-extension.enable "knowledge/secrets/accounts";
      PASSWORD_STORE_DIR = "/home/colin/knowledge/secrets/accounts";
    };
  };
}
