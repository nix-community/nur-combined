# common settings to toggle (at runtime, in about:config):
#   > security.ssl.require_safe_negotiation

# librewolf is a forked firefox which patches firefox to allow more things
# (like default search engines) to be configurable at runtime.
# many of the settings below won't have effect without those patches.
# see: https://gitlab.com/librewolf-community/settings/-/blob/master/distribution/policies.json

{ config, lib, pkgs, ...}:
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

  nativeMessagingHostNames = lib.flatten (
    lib.mapAttrsToList
      (_: addonOpts: lib.optionals addonOpts.enable addonOpts.nativeMessagingHosts)
      cfg.addons
  );
  nativeMessagingPrograms = lib.map (n: config.sane.programs."${n}") nativeMessagingHostNames;
  nativeMessagingHosts = lib.map (p: p.package) nativeMessagingPrograms;

  addonSuggestedProgramNames = lib.flatten (
    lib.mapAttrsToList
      (_: addonOpts: lib.optionals addonOpts.enable addonOpts.suggestedPrograms)
      cfg.addons
  );
  addonSuggestedPrograms = lib.map (n: config.sane.programs."${n}") addonSuggestedProgramNames;
  addonHomePaths = lib.concatMap (p: p.sandbox.extraHomePaths) (addonSuggestedPrograms ++ nativeMessagingPrograms);

  packageUnwrapped = (pkgs.wrapFirefox cfg.browser.browser {
    # inherit the default librewolf.cfg
    # it can be further customized via ~/.librewolf/librewolf.overrides.cfg
    inherit (cfg.browser) extraPrefsFiles libName;
    inherit nativeMessagingHosts;

    nixExtensions = lib.concatMap (ext: lib.optional ext.enable ext.package) (builtins.attrValues cfg.addons);
  }).overrideAttrs (base: {
    nativeBuildInputs = (base.nativeBuildInputs or []) ++ [
      pkgs.copyDesktopItems
    ];
    desktopItems = (base.desktopItems or []) ++ [
      (pkgs.makeDesktopItem {
        name = "${cfg.browser.libName}-in-vpn";
        desktopName = "${cfg.browser.libName} (VPN)";
        genericName = "Web Browser";
        # N.B.: --new-instance ensures we don't reuse an existing differenty-namespaced instance.
        # OTOH, it may error about "only one instance can run at a time": close the other instance if you see that.
        exec = "${lib.getExe pkgs.sane-scripts.vpn} do default -- ${cfg.browser.libName} --new-instance";
        icon = cfg.browser.libName;
        categories = [ "Network" "WebBrowser" ];
        type = "Application";
      })
      (pkgs.makeDesktopItem {
        name = "${cfg.browser.libName}-stub-dns";
        desktopName = "${cfg.browser.libName} (stub DNS)";
        genericName = "Web Browser";
        # N.B.: --new-instance ensures we don't reuse an existing differently-namespaced instance.
        # OTOH, it may error about "only one instance can run at a time": close the other instance if you see that.
        exec = "${lib.getExe pkgs.sane-scripts.vpn} do none -- ${cfg.browser.libName} --new-instance";
        icon = cfg.browser.libName;
        categories = [ "Network" "WebBrowser" ];
        type = "Application";
      })
    ];

    # TODO: could use `zip -f` to only update the one changed file, instead of rezipping everything.
    buildCommand = (base.buildCommand or "") + ''
      mkdir omni

      echo "omni.ja BEFORE:"
      ls -l $(readlink $out/lib/${cfg.browser.libName}/browser/omni.ja)

      echo "unzipping omni.ja"
      # N.B. `zip` exits non-zero even on successful extraction, if the file didn't 100% obey spec
      ${lib.getExe pkgs.buildPackages.unzip} $out/lib/${cfg.browser.libName}/browser/omni.ja -d omni || true

      echo "removing old omni.ja"
      rm $out/lib/${cfg.browser.libName}/browser/omni.ja

      echo "patching omni.ja"
      # de-associate `ctrl+shift+c` from activating the devtools.
      # see: <https://stackoverflow.com/a/54260938>
      ${lib.getExe pkgs.buildPackages.gnused} -i s'/devtools-commandkey-inspector = C/devtools-commandkey-inspector = VK_F12/' omni/localization/en-US/devtools/startup/key-shortcuts.ftl
      # remap Close Tab shortcut from Ctrl+W to Ctrl+Shift+W
      # see: <https://www.math.cmu.edu/~gautam/sj/blog/20220329-firefox-disable-ctrl-w.html>
      ${lib.getExe pkgs.buildPackages.gnused} -i s'/command="cmd_close" modifiers="accel"/command="cmd_close" modifiers="accel,shift"/' omni/chrome/browser/content/browser/browser.xhtml

      echo "re-zipping omni.ja"
      pushd omni; ${lib.getExe pkgs.buildPackages.zip} $out/lib/${cfg.browser.libName}/browser/omni.ja -r ./*; popd

      echo "omni.ja AFTER:"
      ls -l $out/lib/${cfg.browser.libName}/browser/omni.ja

      runHook postBuild
      runHook postInstall
      runHook postFixup
    '';
  });
in
{
  imports = [
    ./addons.nix
    ./browserpass.nix
    ./passff-host.nix
  ];

  sane.programs.firefox = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
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
            default = {};
            type = types.attrsOf (types.submodule ({ name, ...}: {
              options = {
                enable = mkEnableOption "enable the ${name} Firefox addon";
                package = mkPackageOption pkgs.firefox-extensions name {};
                nativeMessagingHosts = mkOption {
                  type = types.listOf types.str;
                  default = [];
                };
                suggestedPrograms = mkOption {
                  type = types.listOf types.str;
                  default = [];
                };
              };
            }));
          };
        };
      };
    };

    inherit packageUnwrapped;

    suggestedPrograms = nativeMessagingHostNames ++ addonSuggestedProgramNames;

    sandbox.net = "all";
    sandbox.whitelistAudio = true;
    sandbox.whitelistAvDev = true;  #< it doesn't seem to use pipewire, but direct /dev/videoN (as of 2024/09/12)
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
    ] ++ addonHomePaths;

    mime.associations = let
      inherit (cfg.browser) desktop;
    in {
      "text/html" = desktop;
      "x-scheme-handler/http" = desktop;
      "x-scheme-handler/https" = desktop;
      "x-scheme-handler/about" = desktop;
      "x-scheme-handler/unknown" = desktop;
    };

    env.BROWSER = cfg.browser.libName;  # used by misc tools like xdg-email, as fallback

    # redirect librewolf configs to the firefox configs; this way addons don't have to care about the firefox/librewolf distinction.
    fs.".librewolf/librewolf.overrides.cfg".symlink.target = "../.mozilla/firefox/firefox.overrides.cfg";
    fs.".librewolf/profiles.ini".symlink.target = "../.mozilla/firefox/profiles.ini";
    fs.".librewolf/managed-storage".symlink.target = "../.mozilla/firefox/managed-storage";

    # N.B.: `overrides.cfg` might be librewolf-specific -- not supported by mainline firefox.
    # firefox does support per-profile `user.js` files which have similar functionality.
    fs.".mozilla/firefox/firefox.overrides.cfg".symlink.text = ''
      // use `pref(...)` to force a preference
      // use `defaultPref(...)` to allow runtime reconfiguration
      // discover preference names via the `about:config` page
      //
      // if we can't query the revocation status of a SSL cert because the issuer is offline,
      // treat it as unrevoked.
      // see: <https://librewolf.net/docs/faq/#im-getting-sec_error_ocsp_server_error-what-can-i-do>
      defaultPref("security.OCSP.require", false);
      // kinda weird to send ALL my domain connections to a 3rd party server, just disable OCSP
      defaultPref("security.OCSP.enabled", 0);

      // DISABLE DNS OVER HTTPS; use the system resolver.
      defaultPref("network.trr.mode", 5);

      // scrollbar configuration, see: <https://artemis.sh/2023/10/12/scrollbars.html>
      // style=4 gives rectangular scrollbars
      // could also enable "always show scrollbars" in about:preferences -- not sure what the actual pref name for that is
      // note that too-large scrollbars (like 50px wide, even 20px) tend to obscure content (and make buttons unclickable)
      defaultPref("widget.non-native-theme.scrollbar.size.override", 14);
      defaultPref("widget.non-native-theme.scrollbar.style", 4);

      // disable inertial/kinetic/momentum scrolling because it just gets in the way on touchpads
      // source: <https://kparal.wordpress.com/2019/10/31/disabling-kinetic-scrolling-in-firefox/>
      defaultPref("apz.gtk.kinetic_scroll.enabled", false);

      // uidensity=2 gives more padding around UI elements.
      // source: <https://codeberg.org/user0/Mobile-Friendly-Firefox>
      defaultPref("browser.uidensity", 2);

      // open external URIs/files via xdg-desktop-portal.
      defaultPref("widget.use-xdg-desktop-portal.mime-handler", 1);
      defaultPref("widget.use-xdg-desktop-portal.open-uri", 1);

      defaultPref("browser.toolbars.bookmarks.visibility", "never");
      // configure which extensions are visible by default (TODO: requires a lot of trial and error)
      // defaultPref("browser.uiCustomization.state", ...);

      // auto-open specific URI schemes without prompting:
      defaultPref("network.protocol-handler.external.xdg-open", true); // for firefox-xdg-open extension
      defaultPref("network.protocol-handler.external.mpv", true); // for open-in-mpv extension
      defaultPref("network.protocol-handler.external.element", true); // for Element matrix client
      defaultPref("network.protocol-handler.external.matrix", true); // for Nheko matrix client

      // statically configure bookmarks.
      // notably, these bookmarks have "shortcut url" fields:
      // - type `w thing` into the URL bar to search "thing" on Wikipedia.
      // - to add a search shortcut: right-click any search box => "Add a keyword for this search".
      // - to update the static bookmarks, export via Hamburger => bookmarks => manage bookmarks => Import and Backup => Export Bookmarks To HTML
      defaultPref("browser.places.importBookmarksHTML", true);
      defaultPref("browser.bookmarks.file", "~/.mozilla/firefox/bookmarks.html");

      defaultPref("browser.startup.homepage", "https://uninsane.org/places");
    '';

    fs.".mozilla/firefox/bookmarks.html".symlink.target = ./bookmarks.html;

    # instruct Firefox to put the profile in a predictable directory (so we can do things like persist just it).
    # XXX: the directory *must* exist, even if empty; Firefox will not create the directory itself.
    fs.".mozilla/firefox/profiles.ini".symlink.text = ''
      [Profile0]
      Name=default
      IsRelative=1
      Path=default
      Default=1

      [General]
      StartWithLastProfile=1
    '';

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
}
