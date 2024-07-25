# common settings to toggle (at runtime, in about:config):
#   > security.ssl.require_safe_negotiation

# librewolf is a forked firefox which patches firefox to allow more things
# (like default search engines) to be configurable at runtime.
# many of the settings below won't have effect without those patches.
# see: https://gitlab.com/librewolf-community/settings/-/blob/master/distribution/policies.json

{ config, lib, pkgs, ...}:
with lib;
let
  cfg = config.sane.programs.firefox.config;
  mobile-prefs = lib.optionals false pkgs.librewolf-pmos-mobile.extraPrefsFiles;
  # allow easy switching between firefox and librewolf with `defaultSettings`, below
  librewolfSettings = {
    browser = pkgs.librewolf-unwrapped.overrideAttrs (upstream: {
      # TEMP(2023/11/21): fix eval bug in wrapFirefox
      # see: <https://github.com/NixOS/nixpkgs/pull/244591>
      passthru = upstream.passthru // {
        requireSigning = false;
        allowAddonSideload = true;
      };
    });
    extraPrefsFiles = pkgs.librewolf-unwrapped.extraPrefsFiles ++ mobile-prefs;
    libName = "librewolf";
    dotDir = ".librewolf";
    cacheDir = ".cache/librewolf";
    desktop = "librewolf.desktop";
  };
  firefoxSettings = {
    browser = pkgs.firefox-esr-unwrapped;
    extraPrefsFiles = mobile-prefs;
    libName = "firefox";
    dotDir = ".mozilla/firefox";
    cacheDir = ".cache/mozilla";
    desktop = "firefox.desktop";
  };
  # defaultSettings = firefoxSettings;
  defaultSettings = librewolfSettings;

  packageUnwrapped = (pkgs.wrapFirefox cfg.browser.browser {
    # inherit the default librewolf.cfg
    # it can be further customized via ~/.librewolf/librewolf.overrides.cfg
    inherit (cfg.browser) extraPrefsFiles libName;

    nativeMessagingHosts = lib.optionals cfg.addons.browserpass-extension.enable [
      pkgs.browserpass
    ] ++ lib.optionals cfg.addons.fxCast.enable [
      pkgs.fx-cast-bridge
    ];

    nixExtensions = concatMap (ext: optional ext.enable ext.package) (attrValues cfg.addons);

    extraPolicies = {
      FirefoxHome = {
        Search = true;
        Pocket = false;
        Snippets = false;
        TopSites = false;
        Highlights = false;
      };
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      PasswordManagerEnabled = false;
      SearchEngines = {
        Default = "DuckDuckGo";
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        SkipOnboarding = true;
        UrlbarInterventions = false;
        WhatsNew = false;
      };

      # these were taken from Librewolf
      AppUpdateURL = "https://localhost";
      DisableAppUpdate = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DisableSystemAddonUpdate = true;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DisableFeedbackCommands = true;
      DisablePocket = true;
      DisableSetDesktopBackground = false;

      # remove many default search providers
      # XXX this seems to prevent the `nixExtensions` from taking effect
      # Extensions.Uninstall = [
      #   "google@search.mozilla.org"
      #   "bing@search.mozilla.org"
      #   "amazondotcom@search.mozilla.org"
      #   "ebay@search.mozilla.org"
      #   "twitter@search.mozilla.org"
      # ];
      # XXX doesn't seem to have any effect...
      # docs: https://github.com/mozilla/policy-templates#homepage
      # Homepage = {
      #   HomepageURL = "https://uninsane.org/";
      #   StartPage = "homepage";
      # };
      # NewTabPage = true;
    };
    # extraPrefs = ...
  }).overrideAttrs (base: {
    # de-associate `ctrl+shift+c` from activating the devtools.
    # based on <https://stackoverflow.com/a/54260938>
    # TODO: could use `zip -f` to only update the one changed file, instead of rezipping everything.
    buildCommand = (base.buildCommand or "") + ''
      mkdir omni

      echo "omni.ja BEFORE:"
      ls -l $(readlink $out/lib/${cfg.browser.libName}/browser/omni.ja)

      echo "unzipping omni.ja"
      # N.B. `zip` exits non-zero even on successful extraction, if the file didn't 100% obey spec
      ${pkgs.buildPackages.unzip}/bin/unzip $out/lib/${cfg.browser.libName}/browser/omni.ja -d omni || true

      echo "removing old omni.ja"
      rm $out/lib/${cfg.browser.libName}/browser/omni.ja

      echo "patching omni.ja"
      ${pkgs.buildPackages.gnused}/bin/sed -i s'/devtools-commandkey-inspector = C/devtools-commandkey-inspector = VK_F12/' omni/localization/en-US/devtools/startup/key-shortcuts.ftl

      echo "re-zipping omni.ja"
      pushd omni; ${pkgs.buildPackages.zip}/bin/zip $out/lib/${cfg.browser.libName}/browser/omni.ja -r ./*; popd

      echo "omni.ja AFTER:"
      ls -l $out/lib/${cfg.browser.libName}/browser/omni.ja

      # runHook postFixup to allow sane.programs sandbox wrappers to wrap the binaries
      runHook postFixup
    '';
  });

  addonOpts = types.submodule {
    options = {
      package = mkOption {
        type = types.package;
      };
      enable = mkOption {
        type = types.bool;
      };
    };
  };

  configOpts = {
    options = {
      browser = mkOption {
        default = defaultSettings;
        type = types.anything;
      };
      persistData = mkOption {
        description = "optional store name to which persist browsing data (like history)";
        type = types.nullOr types.str;
        default = null;
      };
      persistCache = mkOption {
        description = "optional store name to which persist browser cache";
        type = types.nullOr types.str;
        default = "ephemeral";
      };
      addons = mkOption {
        type = types.attrsOf addonOpts;
        default = {};
      };
    };
  };
in
{
  config = mkMerge [
    ({
      sane.programs.firefox.configOption = mkOption {
        type = types.submodule configOpts;
        default = {};
      };
      sane.programs.firefox.config.addons = {
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
          enable = lib.mkDefault config.sane.programs.open-in-mpv.enabled;
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
    })
    ({
      sane.programs.firefox = {
        inherit packageUnwrapped;
        sandbox.method = "bwrap";  # landlock works, but requires all of /proc to be linked
        sandbox.wrapperType = "inplace";  # trivial package; cheap enough to wrap inplace
        sandbox.net = "all";
        sandbox.whitelistAudio = true;
        sandbox.whitelistDbus = [ "user" ];  # mpris
        sandbox.whitelistWayland = true;
        sandbox.extraHomePaths = [
          "dev"  # for developing anything web-related
          # for uploads/downloads.
          # it still needs these paths despite using the portal's file-chooser :?
          "tmp"
          "Pictures/albums"
          "Pictures/cat"
          "Pictures/from"
          "Pictures/Photos"
          "Pictures/Screenshots"
          "Pictures/servo-macros"
        ] ++ lib.optionals cfg.addons.browserpass-extension.enable [
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

        suggestedPrograms = [
          "open-in-mpv"
        ];

        mime.associations = let
          inherit (cfg.browser) desktop;
        in {
          "text/html" = desktop;
          "x-scheme-handler/http" = desktop;
          "x-scheme-handler/https" = desktop;
          "x-scheme-handler/about" = desktop;
          "x-scheme-handler/unknown" = desktop;
        };

        # env.BROWSER = "${package}/bin/${cfg.browser.libName}";
        env.BROWSER = cfg.browser.libName;  # used by misc tools like xdg-email, as fallback

        # uBlock configuration:
        fs."${cfg.browser.dotDir}/managed-storage/uBlock0@raymondhill.net.json".symlink.target = cfg.addons.ublock-origin.package.makeConfig {
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

        # TODO: this is better suited in `extraPrefs` during `wrapFirefox` call
        fs."${cfg.browser.dotDir}/${cfg.browser.libName}.overrides.cfg".symlink.text = ''
          // if we can't query the revocation status of a SSL cert because the issuer is offline,
          // treat it as unrevoked.
          // see: <https://librewolf.net/docs/faq/#im-getting-sec_error_ocsp_server_error-what-can-i-do>
          defaultPref("security.OCSP.require", false);

          // scrollbar configuration, see: <https://artemis.sh/2023/10/12/scrollbars.html>
          // style=4 gives rectangular scrollbars
          // could also enable "always show scrollbars" in about:preferences -- not sure what the actual pref name for that is
          // note that too-large scrollbars (like 50px wide, even 20px) tend to obscure content (and make buttons unclickable)
          defaultPref("widget.non-native-theme.scrollbar.size.override", 14);
          defaultPref("widget.non-native-theme.scrollbar.style", 4);

          // disable inertial/kinetic/momentum scrolling because it just gets in the way on touchpads
          // source: <https://kparal.wordpress.com/2019/10/31/disabling-kinetic-scrolling-in-firefox/>
          defaultPref("apz.gtk.kinetic_scroll.enabled", false);

          // open external URIs/files via xdg-desktop-portal.
          defaultPref("widget.use-xdg-desktop-portal.mime-handler", 1);
          defaultPref("widget.use-xdg-desktop-portal.open-uri", 1);

          defaultPref("browser.toolbars.bookmarks.visibility", "never");
          // configure which extensions are visible by default (TODO: requires a lot of trial and error)
          // defaultPref("browser.uiCustomization.state", ...);

          // auto-open mpv:// URIs without prompting.
          // can do this with other protocols too (e.g. matrix?). see about:config for common handlers.
          defaultPref("network.protocol-handler.external.mpv", true);
          // element:// for Element matrix client
          defaultPref("network.protocol-handler.external.element", true);
          // matrix: for Nheko matrix client
          defaultPref("network.protocol-handler.external.matrix", true);
        '';
        # instruct Firefox to put the profile in a predictable directory (so we can do things like persist just it).
        # XXX: the directory *must* exist, even if empty; Firefox will not create the directory itself.
        fs."${cfg.browser.dotDir}/profiles.ini".symlink.text = ''
          [Profile0]
          Name=default
          IsRelative=1
          Path=default
          Default=1

          [General]
          StartWithLastProfile=1
        '';

        # TODO: env.PASSWORD_STORE_DIR only needs to be present within the browser session.
        env.PASSWORD_STORE_DIR = "/home/colin/knowledge/secrets/accounts";
        # alternative to PASSWORD_STORE_DIR:
        # fs.".password-store".symlink.target = lib.mkIf cfg.addons.browserpass-extension.enable "knowledge/secrets/accounts";

        # flush the cache to disk to avoid it taking up too much tmp.
        persist.byPath."${cfg.browser.cacheDir}".store =
          if (cfg.persistData != null) then
            cfg.persistData
          else
            "ephemeral"
        ;

        persist.byPath."${cfg.browser.dotDir}/default".store =
          if (cfg.persistData != null) then
            cfg.persistData
          else
            "ephemeral"
        ;
      };

    })
  ];
}
