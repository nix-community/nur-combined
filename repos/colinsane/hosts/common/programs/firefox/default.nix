{ config, lib, pkgs, ...}:
let
  cfg = config.sane.programs.firefox.config;

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
  addonHomePaths = lib.concatMap
    (p: p.sandbox.extraHomePaths ++ builtins.attrNames p.fs)
    (addonSuggestedPrograms ++ nativeMessagingPrograms);

  packageUnwrapped = let
    unwrapped = pkgs.firefox-unwrapped // {
      # i configure these post wrapping (below), but the wrapper errors if it thinks the browser was built
      # with a different config
      allowAddonSideload = true;
      requireSigning = false;
    };
  in (pkgs.wrapFirefox unwrapped {
    # inherit the default librewolf.cfg
    # it can be further customized via ~/.librewolf/librewolf.overrides.cfg
    libName = "firefox";
    # XXX(2025-08-26): nativeMessagingHosts wrapping is broken! put things in ~/.mozilla/native-messaging-hosts/ instead.
    # inherit nativeMessagingHosts;

    nixExtensions = lib.concatMap (ext: lib.optional ext.enable ext.package) (builtins.attrValues cfg.addons);

    extraPrefsFiles = [
      "${pkgs.arkenfox-userjs}/user.cfg"
      (pkgs.writeText "mozilla.cfg" ''
        // load additional preferences from user directory; inspired by librewolf
        let home_dir;
        if (home_dir = getenv('HOME')) {
          defaultPref('autoadmin.global_config_url', `file://''${home_dir}/.mozilla/firefox/user.js`);
        }
      '')
    ]; # ++ pkgs.librewolf-pmos-mobile.extraPrefsFiles

    extraPolicies = {
      # firefox policy schema is documented in <repo:mozilla-firefox/firefox:browser/components/enterprisepolicies/schemas/policies-schema.json>
      # and <https://mozilla.github.io/policy-templates>
      # however the bulk of them seem to not actually have any effect T_T
      #
      # XXX(2024-12-02): using `nixExtensions` causes `about:debugging` to be blocked.
      # i guess this is because the page can install extensions, or something.
      # fuck that, enable it by brute force
      ExtensionSettings = {
        "*" = {
          installation_mode = "allowed";
        };
      };
      PasswordManagerEnabled = false;  #< TODO(2025-05-31): does this actually have an effect?
      # see also ~/.mozilla/firefox/default/search.json.mozlz4
      # (use mozlz4a package to view)
      # XXX(2025-05-31): the below SearchEngines policy has no observable effect.
      # SearchEngines = {
      #   Add = [];
      #   # Default = "search@kagi.comdefault";
      #   Default = "ddg";  #< builtin
      #   DefaultPrivate = "ddg";  #< builtin
      #   PreventInstalls = false;
      #   Remove = [];
      # };
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
        name = "firefox-in-vpn";
        desktopName = "Firefox (VPN)";
        genericName = "Web Browser";
        # N.B.: --new-instance ensures we don't reuse an existing differenty-namespaced instance.
        # OTOH, it may error about "only one instance can run at a time": close the other instance if you see that.
        exec = "${lib.getExe pkgs.sane-scripts.vpn} do default -- firefox --new-instance";
        icon = "firefox";
        categories = [ "Network" "WebBrowser" ];
        type = "Application";
      })
      (pkgs.makeDesktopItem {
        name = "firefox-stub-dns";
        desktopName = "Firefox (Stub DNS)";
        genericName = "Web Browser";
        # N.B.: --new-instance ensures we don't reuse an existing differently-namespaced instance.
        # OTOH, it may error about "only one instance can run at a time": close the other instance if you see that.
        exec = "${lib.getExe pkgs.sane-scripts.vpn} do none -- firefox --new-instance";
        icon = "firefox";
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
        ls -l $(readlink $out/lib/firefox/$ja)

        echo "unzipping $ja"
        # N.B. `zip` exits non-zero even on successful extraction, if the file didn't 100% obey spec
        unzip $out/lib/firefox/$ja -d $name || true

        echo "removing old $ja"
        rm $out/lib/firefox/$ja

        (
          pushd $name
          echo "patching $ja"
          patch_''${name}_hook

          echo "re-zipping $ja"
          zip $out/lib/firefox/$ja -r ./*
          popd
        )

        echo "$ja: AFTER:"
        ls -l $out/lib/firefox/$ja
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
    sandbox.whitelistDbus.user.own = [
      "org.mozilla.firefox.*"
      "org.mpris.MediaPlayer2.firefox.*"
    ];
    sandbox.whitelistPortal = [
      "Camera"  # not sure if used
      # "Email"  # not sure if used
      "FileChooser"
      "Location"  # not sure if used
      "OpenURI"
      "Print"  # not sure if used
      "ScreenCast"  # not sure if used
    ];
    sandbox.whitelistSecurityKeys = true;
    sandbox.whitelistSendNotifications = true;
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

    sandbox.tmpDir = ".cache/mozilla/tmp";
    sandbox.mesaCacheDir = ".cache/mozilla/mesa";

    mime.associations = let
      desktop = "firefox.desktop";
    in {
      "text/html" = desktop;
      "x-scheme-handler/http" = desktop;
      "x-scheme-handler/https" = desktop;
      "x-scheme-handler/about" = desktop;
      "x-scheme-handler/unknown" = desktop;
    };

    env.BROWSER = "firefox";  # used by misc tools like xdg-email, as fallback

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

    fs.".mozilla/firefox/user.js".symlink.target = ./user.js;
    fs.".mozilla/firefox/default/search.json.mozlz4".symlink.target = let
      drv = pkgs.stdenvNoCC.mkDerivation {
        # Mozilla uses a custom compression scheme for `search.json` because they're ASSHOLES.
        # seriously, why do you need to compress this 2 KiB file? and then why do you need to INVENT YOUR OWN COMPRESSION FORMAT FOR THAT?
        # GET YOUR HEAD OUT OF YOUR ASS.
        #
        # search.json fields:
        # - `metaData.defaultEngineIdHash`: this is a digest of the defaultEngineId _value_, plus some legalese text;
        #   compute this either by manually updating the search engine in firefox and seeing what it generates,
        #   or, see the code for it in <repo:nix-community/home-manager>
        name = "search.json.mozlz4";
        src = ./.;
        nativeBuildInputs = with pkgs; [ mozlz4a ];
        buildPhase = ''
          mozlz4a ./search.json search.json.mozlz4
        '';
        installPhase = ''
          install -D search.json.mozlz4 "$out"/search.json.mozlz4
        '';
      };
    in "${drv}/search.json.mozlz4";

    # flush the cache to disk to avoid it taking up too much tmp.
    persist.byPath = let
      maybePersist = if (cfg.persistData != null) then
        cfg.persistData
      else
        "ephemeral"
      ;
    in {
      ".cache/mozilla".store = maybePersist;
      # storage consumes 80+ MB
      # the other profile dirs take significantly less; < 20MB total
      ".mozilla/firefox/default/storage".store = maybePersist;
      # profile files (.mozilla/firefox/default/...):
      # - addons.json
      #   - regenerated on launch
      # - addonStartup.json.lz4
      #   - regenerated on next-next launch
      # - bookmarkbackups/
      # - bounce-tracking-protection.sqlite
      #   - recreated on launch
      # - cert9.db
      #   - regenerated on launch
      # - compatibility.ini
      #   - regenerated on launch
      # - containers.json
      #   - regenerated on launch
      # - content-prefs.sqlite
      #   - recreated on launch
      # - cookies.sqlite{,-wal}
      #   - recreated on launch
      # - crashes/
      # - datareporting/
      # - domain_to_categories.sqlite{,-journal}
      #   - recreated on launch
      # - enumerate_devices.txt
      #   - recreated on launch
      # - extension-preferences.json
      #   - NOT recreated, but inconsequential to delete
      # - extension-settings.json
      #   - regenerated on launch
      # - extension-store/
      # - extension-store-menus/
      # - extensions/
      # - extensions.json
      #   - regenerated on launch
      # - failover.jsc
      #   - regenerated on launch
      # - favicons.sqlite{,-wal}
      #   - regenerated on launch
      # - formhistory.sqlite
      #   - recreated on launch
      # - handlers.json
      #   - NOT recreated, but inconsequential to delete
      # - key4.db
      #   - recreated on launch
      # - lock -> ...
      # - minidumps/
      # - permissions.sqlite
      #   - recreated on launch
      # - pkcs11.txt
      #   - regenerated on launch
      # - places.sqlite{,-wal}
      #   - recreated on launch
      # - prefs.js
      #   - recreated on launch
      # - protections.sqlite
      #   - recreated on launch
      # - search.json.mozlz4
      #   - recreated on launch; loses any customized search engines
      # - security_state/
      # - serviceworker.txt
      #   - NOT recreated, but inconsequential to delete
      # - sessionCheckpoints.json
      #   - recreated on launch
      # - shield-preference-experiments.json
      #   - NOT recreated, but inconsequential to delete
      # - storage/
      # - storage-sync-v2.sqlite
      #   - recreated on launch
      # - storage.sqlite
      # - times.json
      #   - recreated on launch
      # - xulstore.json
      #   - recreated on launch
    };
  };
}
