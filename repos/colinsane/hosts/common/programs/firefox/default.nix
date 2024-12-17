# common settings to toggle (at runtime, in about:config):
#   > security.ssl.require_safe_negotiation

# librewolf is a forked firefox which patches firefox to allow more things
# (like default search engines) to be configurable at runtime.
# many of the settings below won't have effect without those patches.
# see: https://gitlab.com/librewolf-community/settings/-/blob/master/distribution/policies.json

{ config, lib, pkgs, ...}:
let
  cfg = config.sane.programs.firefox.config;
  arkenfox-prefs = "${pkgs.arkenfox-userjs}/user.cfg";
  librewolf-prefs = pkgs.librewolf-unwrapped.extraPrefsFiles;
  mobile-prefs = lib.optionals false pkgs.librewolf-pmos-mobile.extraPrefsFiles;
  # allow easy switching between firefox and librewolf with `defaultSettings`, below
  librewolfSettings = {
    browser = pkgs.librewolf-unwrapped;
    extraPrefsFiles = [ librewolf-prefs ];
    libName = "librewolf";
    dotDir = ".librewolf";
    cacheDir = ".cache/librewolf";
  };
  firefoxSettings = {
    # browser = pkgs.firefox-esr-unwrapped;
    browser = pkgs.firefox-unwrapped;
    # arkenfox does privacy-enhancing and anti-fingerprinting
    extraPrefsFiles = [ arkenfox-prefs ];
    libName = "firefox";
    dotDir = ".mozilla/firefox";
    cacheDir = ".cache/mozilla";
  };
  defaultSettings = firefoxSettings;
  # defaultSettings = librewolfSettings;

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

  packageUnwrapped = let
    unwrapped = cfg.browser.browser // {
      # i configure these post wrapping (below), but the wrapper errors if it thinks the browser was built
      # with a different config
      allowAddonSideload = true;
      requireSigning = false;
    };
  in (pkgs.wrapFirefox unwrapped {
    # inherit the default librewolf.cfg
    # it can be further customized via ~/.librewolf/librewolf.overrides.cfg
    inherit (cfg.browser) libName;
    inherit nativeMessagingHosts;

    nixExtensions = lib.concatMap (ext: lib.optional ext.enable ext.package) (builtins.attrValues cfg.addons);

    extraPrefsFiles = cfg.browser.extraPrefsFiles ++ mobile-prefs ++ [
      (pkgs.writeText "mozilla.cfg" ''
        // load additional preferences from user directory; inspired by librewolf
        let home_dir;
        if (home_dir = getenv('HOME')) {
          defaultPref('autoadmin.global_config_url', `file://''${home_dir}/.mozilla/firefox/user.js`);
        }
      '')
    ];

    extraPolicies = {
      # XXX(2024-12-02): using `nixExtensions` causes `about:debugging` to be blocked.
      # i guess this is because the page can install extensions, or something.
      # fuck that, enable it by brute force
      ExtensionSettings = {
        "*" = {
          installation_mode = "allowed";
        };
      };
    };
  }).overrideAttrs (base: {
    nativeBuildInputs = (base.nativeBuildInputs or []) ++ [
      pkgs.copyDesktopItems
      pkgs.gnused
      pkgs.unzip
      pkgs.zip
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
        desktopName = "${cfg.browser.libName} (Stub DNS)";
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
      patchOmni() {
        local name="$1"
        local ja="$2"

        mkdir $name
        echo "$ja: BEFORE:"
        ls -l $(readlink $out/lib/${cfg.browser.libName}/$ja)

        echo "unzipping $ja"
        # N.B. `zip` exits non-zero even on successful extraction, if the file didn't 100% obey spec
        unzip $out/lib/${cfg.browser.libName}/$ja -d $name || true

        echo "removing old $ja"
        rm $out/lib/${cfg.browser.libName}/$ja

        (
          pushd $name
          echo "patching $ja"
          patch_''${name}_hook

          echo "re-zipping $ja"
          zip $out/lib/${cfg.browser.libName}/$ja -r ./*
          popd
        )

        echo "$ja: AFTER:"
        ls -l $out/lib/${cfg.browser.libName}/$ja
      }

      patch_browser_omni_hook() {
        # de-associate `ctrl+shift+c` from activating the devtools.
        # see: <https://stackoverflow.com/a/54260938>
        sed -i s'/devtools-commandkey-inspector = C/devtools-commandkey-inspector = VK_F12/' localization/en-US/devtools/startup/key-shortcuts.ftl

        # remap Close Tab shortcut from Ctrl+W to Ctrl+Shift+W
        # see: <https://www.math.cmu.edu/~gautam/sj/blog/20220329-firefox-disable-ctrl-w.html>
        sed -i s'/command="cmd_close" modifiers="accel"/command="cmd_close" modifiers="accel,shift"/' chrome/browser/content/browser/browser.xhtml
      }

      patch_toplevel_omni_hook() {
        # allow loading "unsigned" addons (i.e. the ones i fucking build FROM SOURCE).
        # required for Mozilla firefox; not for Librewolf
        # alternative implementations require a rebuild:
        # - nixpkgs `allowAddonSideload = true;`
        # - configure flag `--allow-addond-sideload`
        sed -i s'/MOZ_ALLOW_ADDON_SIDELOAD:/MOZ_ALLOW_ADDON_SIDELOAD: true, _OLD_MOZ_ALLOW_ADDON_SIDELOAD:/' modules/AppConstants.sys.mjs
        sed -i s'/MOZ_REQUIRE_SIGNING:/MOZ_REQUIRE_SIGNING: false, _OLD_MOZ_REQUIRE_SIGNING:/' modules/AppConstants.sys.mjs
      }

      patchOmni "browser_omni" "browser/omni.ja"
      patchOmni "toplevel_omni" "omni.ja"

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
          formFactor = mkOption {
            default = "other";
            type = types.enum [
              "desktop"
              "laptop"
              "other"
            ];
            description = ''
              tune the browser experience for a specific form factor
            '';
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

    sandbox.tmpDir = "${cfg.browser.cacheDir}/tmp";

    mime.associations = let
      desktop = "${cfg.browser.browser.meta.mainProgram}.desktop";
    in {
      "text/html" = desktop;
      "x-scheme-handler/http" = desktop;
      "x-scheme-handler/https" = desktop;
      "x-scheme-handler/about" = desktop;
      "x-scheme-handler/unknown" = desktop;
    };

    env.BROWSER = cfg.browser.libName;  # used by misc tools like xdg-email, as fallback

    fs = {
      ".mozilla/firefox/bookmarks.html".symlink.target = ./bookmarks.html;

      # instruct Firefox to put the profile in a predictable directory (so we can do things like persist just it).
      # XXX: the directory *must* exist, even if empty; Firefox will not create the directory itself.
      ".mozilla/firefox/profiles.ini".symlink.text = ''
        [Profile0]
        Name=default
        IsRelative=1
        Path=default
        Default=1

        [General]
        StartWithLastProfile=1
      '';

      ".mozilla/firefox/user.js".symlink.target = ./user.js;

    } // lib.optionalAttrs (cfg.browser.dotDir != ".mozilla/firefox") {
      # redirect librewolf configs to the firefox configs; this way addons don't have to care about the firefox/librewolf distinction.
      # XXX: this `../` logic assumes `dotDir` is a direct child of ~, and not a path with multiple components!
      fs."${cfg.browser.dotDir}/profiles.ini".symlink.target = "../.mozilla/firefox/profiles.ini";
      # N.B.: `~/.mozilla/managed-storage`, not `~/.mozilla/firefox/managed-storage`
      fs."${cfg.browser.dotDir}/managed-storage".symlink.target = "../.mozilla/managed-storage";
    };

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
