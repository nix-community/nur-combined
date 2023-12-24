# this supports being used as an overlay or in a standalone context
# - if overlay, invoke as `(final: prev: import ./. { inherit final; pkgs = prev; })`
# - if standalone: `import ./. { inherit pkgs; }`
#
# using the correct invocation is critical if any packages mentioned here are
# additionally patched elsewhere
#
{ pkgs ? import <nixpkgs> {}, final ? null }:
let
  lib = pkgs.lib;
  unpatched = pkgs;

  pythonPackagesOverlayFor = pkgs: py-final: py-prev: import ./python-packages {
    inherit (py-final) callPackage;
    inherit pkgs;
  };
  final' = if final != null then final else pkgs.appendOverlays [(_: _: sane-overlay)];
  sane-additional = with final'; {
    sane-data = import ../modules/data { inherit lib sane-lib; };
    sane-lib = import ../modules/lib final';

    ### ADDITIONAL PACKAGES
    alsa-ucm-conf-sane = callPackage ./additional/alsa-ucm-conf-sane { };
    bonsai = callPackage ./additional/bonsai { };
    bootpart-uefi-x86_64 = callPackage ./additional/bootpart-uefi-x86_64 { };
    cargoDocsetHook = callPackage ./additional/cargo-docset/hook.nix { };
    chatty-latest = callPackage ./additional/chatty-latest { };
    codemadness-frontends = callPackage ./additional/codemadness-frontends { };
    codemadness-frontends_0_6 = codemadness-frontends.v0_6;
    delfin = callPackage ./additional/delfin { };
    eg25-control = callPackage ./additional/eg25-control { };
    eg25-manager = callPackage ./additional/eg25-manager { };
    feeds = lib.recurseIntoAttrs (callPackage ./additional/feeds { });
    firefox-extensions = lib.recurseIntoAttrs (callPackage ./additional/firefox-extensions { });
    flare-signal-nixified = callPackage ./additional/flare-signal-nixified { };
    gopass-native-messaging-host = callPackage ./additional/gopass-native-messaging-host { };
    gpodder-adaptive = callPackage ./additional/gpodder-adaptive { };
    gpodder-adaptive-configured = callPackage ./additional/gpodder-configured {
      gpodder = final'.gpodder-adaptive;
    };
    gpodder-configured = callPackage ./additional/gpodder-configured { };
    jellyfin-media-player-qt6 = callPackage ./additional/jellyfin-media-player-qt6 { };
    koreader-from-src = callPackage ./additional/koreader-from-src { };
    ldd-aarch64 = callPackage ./additional/ldd-aarch64 { };
    lemoa = callPackage ./additional/lemoa { };
    lightdm-mobile-greeter = callPackage ./additional/lightdm-mobile-greeter { };
    linux-firmware-megous = callPackage ./additional/linux-firmware-megous { };
    # XXX: eval error: need to port past linux_6_4
    # linux-manjaro = callPackage ./additional/linux-manjaro { };
    linux-megous = callPackage ./additional/linux-megous { };
    mcg = callPackage ./additional/mcg { };
    mx-sanebot = callPackage ./additional/mx-sanebot { };
    phog = callPackage ./additional/phog { };
    pipeline = callPackage ./additional/pipeline { };
    rtl8723cs-firmware = callPackage ./additional/rtl8723cs-firmware { };
    rtl8723cs-wowlan = callPackage ./additional/rtl8723cs-wowlan { };
    sane-scripts = lib.recurseIntoAttrs (callPackage ./additional/sane-scripts { });
    sane-weather = callPackage ./additional/sane-weather { };
    signal-desktop-from-src = callPackage ./additional/signal-desktop-from-src { };
    static-nix-shell = callPackage ./additional/static-nix-shell { };
    sublime-music-mobile = callPackage ./additional/sublime-music-mobile { };
    sxmo-utils = callPackage ./additional/sxmo-utils { };
    tow-boot-pinephone = callPackage ./additional/tow-boot-pinephone { };
    tree-sitter-nix-shell = callPackage ./additional/tree-sitter-nix-shell { };
    trivial-builders = lib.recurseIntoAttrs (callPackage ./additional/trivial-builders { });
    inherit (trivial-builders)
      rmDbusServices
    ;
    unftp = callPackage ./additional/unftp { };
    where-am-i = callPackage ./additional/where-am-i { };
    zecwallet-light-cli = callPackage ./additional/zecwallet-light-cli { };

    # packages i haven't used for a while, may or may not still work
    # fluffychat-moby = callPackage ./additional/fluffychat-moby { };
    fractal-latest = callPackage ./additional/fractal-latest { };
    fractal-nixified = callPackage ./additional/fractal-nixified { };
    # kaiteki = callPackage ./additional/kaiteki { };

    # old rpi packages that may or may not still work
    # bootpart-tow-boot-rpi-aarch64 = callPackage ./additional/bootpart-tow-boot-rpi-aarch64 { };
    # bootpart-u-boot-rpi-aarch64 = callPackage ./additional/bootpart-u-boot-rpi-aarch64 { };
    # tow-boot-rpi4 = callPackage ./additional/tow-boot-rpi4 { };
    # patch rpi uboot with something that fixes USB HDD boot
    # ubootRaspberryPi4_64bit = callPackage ./additional/ubootRaspberryPi4_64bit { };

    # provided by nixpkgs patch or upstream PR
    # i still conditionally callPackage these to make them available to external consumers (like NUR)
    splatmoji = callPackage ./additional/splatmoji { };
  };

  sane-patched = with final'; {
    ### PATCHED PACKAGES

    # XXX: the `inherit`s here are because:
    # - pkgs.callPackage draws from the _final_ package set.
    # - unpatched.XYZ draws (selectively) from the _unpatched_ package set.
    # see <overlays/pkgs.nix>

    # XXX patching this is... really costly.
    # prefer to set ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf-sane}/share/alsa/ucm2" if possible instead.
    # alsa-project = unpatched.alsa-project.overrideScope' (sself: ssuper: {
    #   alsa-ucm-conf = sself.callPackage ./additional/alsa-ucm-conf-sane { inherit (ssuper) alsa-ucm-conf; };
    # });

    browserpass = callPackage ./patched/browserpass { inherit (unpatched) browserpass; };

    cozy = callPackage ./patched/cozy { inherit (unpatched) cozy; };

    engrampa = callPackage ./patched/engrampa { inherit (unpatched) mate; };

    # mozilla keeps nerfing itself and removing configuration options
    firefox-unwrapped = callPackage ./patched/firefox-unwrapped { inherit (unpatched) firefox-unwrapped; };

    gnome = unpatched.gnome.overrideScope' (gself: gsuper: {
      gnome-control-center = gself.callPackage ./patched/gnome-control-center {
        inherit (gsuper) gnome-control-center;
      };
    });

    gocryptfs = callPackage ./patched/gocryptfs { inherit (unpatched) gocryptfs; };

    helix = callPackage ./patched/helix { inherit (unpatched) helix; };

    ibus = callPackage ./patched/ibus { inherit (unpatched) ibus; };

    # jackett doesn't allow customization of the bind address: this will probably always be here.
    jackett = callPackage ./patched/jackett { inherit (unpatched) jackett; };

    # modemmanager = callPackage ./patched/modemmanager { inherit (unpatched) modemmanager; };


    ### PYTHON PACKAGES
    pythonPackagesExtensions = (unpatched.pythonPackagesExtensions or []) ++ [
      (pythonPackagesOverlayFor final')
    ];
    # when this scope's applied as an overlay pythonPackagesExtensions is propagated as desired.
    # but when freestanding (e.g. NUR), it never gets plumbed into the outer pkgs, so we have to do that explicitly.
    python3 = unpatched.python3.override {
      packageOverrides = pythonPackagesOverlayFor final';
    };
  };
  sane-overlay = {
    sane = lib.recurseIntoAttrs (sane-additional // sane-patched);
  }
    # patched packages always override anything:
    // (lib.mapAttrs (pname: _pkg: final'.sane."${pname}") sane-patched)
    # "additional" packages only get added if they've not been upstreamed:
    // (lib.mapAttrs (pname: _pkg: unpatched."${pname}" or final'.sane."${pname}") sane-additional)
  ;
in sane-overlay
