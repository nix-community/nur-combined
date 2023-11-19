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
    browser = pkgs.librewolf-unwrapped;
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

  addon = name: extid: hash: pkgs.fetchFirefoxAddon {
    inherit name hash;
    url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
    # extid can be found by unar'ing the above xpi, and copying browser_specific_settings.gecko.id field
    fixedExtid = extid;
  };
  localAddon = pkg: pkgs.fetchFirefoxAddon {
    inherit (pkg) name;
    src = "${pkg}/share/mozilla/extensions/\\{ec8030f7-c20a-464f-9b0e-13a3a9e97384\\}/${pkg.extid}.xpi";
    fixedExtid = pkg.extid;
  };

  package = pkgs.wrapFirefox cfg.browser.browser {
    # inherit the default librewolf.cfg
    # it can be further customized via ~/.librewolf/librewolf.overrides.cfg
    inherit (cfg.browser) extraPrefsFiles libName;

    extraNativeMessagingHosts = optional cfg.addons.browserpass-extension.enable pkgs.browserpass;
    # extraNativeMessagingHosts = [ pkgs.gopass-native-messaging-host ];

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
  };

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
        default = "cryptClearOnBoot";
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
        browserpass-extension = {
          package = pkgs.firefox-extensions.browserpass-extension;
          enable = lib.mkDefault true;
        };
        bypass-paywalls-clean = {
          package = pkgs.firefox-extensions.bypass-paywalls-clean;
          enable = lib.mkDefault true;
        };
        ether-metamask = {
          package = pkgs.firefox-extensions.ether-metamask;
          enable = lib.mkDefault false;  # until i can disable the first-run notification
        };
        i2p-in-private-browsing = {
          package = pkgs.firefox-extensions.i2p-in-private-browsing;
          enable = lib.mkDefault config.services.i2p.enable;
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
          enable = lib.mkDefault true;
        };
        ublock-origin = {
          package = pkgs.firefox-extensions.ublock-origin;
          enable = lib.mkDefault true;
        };
      };
    })
    ({
      sane.programs.firefox = {
        inherit package;

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

        # uBlock filter list configuration.
        # specifically, enable the GDPR cookie prompt blocker.
        # data.toOverwrite.filterLists is additive (i.e. it supplements the default filters)
        # this configuration method is documented here:
        # - <https://github.com/gorhill/uBlock/issues/2986#issuecomment-364035002>
        # the specific attribute path is found via scraping ublock code here:
        # - <https://github.com/gorhill/uBlock/blob/master/src/js/storage.js>
        # - <https://github.com/gorhill/uBlock/blob/master/assets/assets.json>
        fs."${cfg.browser.dotDir}/managed-storage/uBlock0@raymondhill.net.json".symlink.text = ''
          {
           "name": "uBlock0@raymondhill.net",
           "description": "ignored",
           "type": "storage",
           "data": {
              "toOverwrite": "{\"filterLists\": [\"fanboy-cookiemonster\"]}"
           }
          }
        '';
        # TODO: this is better suited in `extraPrefs` during `wrapFirefox` call
        fs."${cfg.browser.dotDir}/${cfg.browser.libName}.overrides.cfg".symlink.text = ''
          // if we can't query the revocation status of a SSL cert because the issuer is offline,
          // treat it as unrevoked.
          // see: <https://librewolf.net/docs/faq/#im-getting-sec_error_ocsp_server_error-what-can-i-do>
          defaultPref("security.OCSP.require", false);

          // scrollbar configuration, see: <https://artemis.sh/2023/10/12/scrollbars.html>
          // style=4 gives rectangular scrollbars
          // could also enable "always show scrollbars" in about:preferences -- not sure what the actual pref name for that is
          // note that too-large scrollbars (like 50px wide) tend to obscure content (and make buttons unclickable)
          defaultPref("widget.non-native-theme.scrollbar.size.override", 20);
          defaultPref("widget.non-native-theme.scrollbar.style", 4);
        '';
        fs."${cfg.browser.dotDir}/default".dir = {};
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
      };
    })
    (mkIf config.sane.programs.firefox.enabled {
      # TODO: move the persistence into the sane.programs API (above)
      # flush the cache to disk to avoid it taking up too much tmp.
      sane.user.persist.byPath."${cfg.browser.cacheDir}".store =
        if (cfg.persistData != null) then
          cfg.persistData
        else
          "cryptClearOnBoot"
        ;

      sane.user.persist.byPath."${cfg.browser.dotDir}/default".store =
        if (cfg.persistData != null) then
          cfg.persistData
        else
          "cryptClearOnBoot"
        ;
    })
  ];
}
