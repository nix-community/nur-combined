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
    blast-ugjka = callPackage ./additional/blast-ugjka { };
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
    geary-gtk4 = callPackage ./additional/geary-gtk4 { };
    gopass-native-messaging-host = callPackage ./additional/gopass-native-messaging-host { };
    gpodder-adaptive = callPackage ./additional/gpodder-adaptive { };
    gpodder-adaptive-configured = callPackage ./additional/gpodder-configured {
      gpodder = final'.gpodder-adaptive;
    };
    gpodder-configured = callPackage ./additional/gpodder-configured { };
    jellyfin-media-player-qt6 = callPackage ./additional/jellyfin-media-player-qt6 { };
    koreader-from-src = callPackage ./additional/koreader-from-src { };
    landlock-sandboxer = callPackage ./additional/landlock-sandboxer { };
    ldd-aarch64 = callPackage ./additional/ldd-aarch64 { };
    lemoa = callPackage ./additional/lemoa { };
    lemmy-lemonade = callPackage ./additional/lemonade { };  # XXX: nixpkgs already has a `lemonade` pkg
    lightdm-mobile-greeter = callPackage ./additional/lightdm-mobile-greeter { };
    linux-firmware-megous = callPackage ./additional/linux-firmware-megous { };
    # XXX: eval error: need to port past linux_6_4
    # linux-manjaro = callPackage ./additional/linux-manjaro { };
    linux-megous = callPackage ./additional/linux-megous { };
    mcg = callPackage ./additional/mcg { };
    mx-sanebot = callPackage ./additional/mx-sanebot { };
    peerswap = callPackage ./additional/peerswap { };
    phog = callPackage ./additional/phog { };
    pipeline = callPackage ./additional/pipeline { };
    rtl8723cs-firmware = callPackage ./additional/rtl8723cs-firmware { };
    rtl8723cs-wowlan = callPackage ./additional/rtl8723cs-wowlan { };
    sane-die-with-parent = callPackage ./additional/sane-die-with-parent { };
    sane-open-desktop = callPackage ./additional/sane-open-desktop { };
    sane-sandboxed = callPackage ./additional/sane-sandboxed { };
    sane-screenshot = callPackage ./additional/sane-screenshot { };
    sane-scripts = lib.recurseIntoAttrs (callPackage ./additional/sane-scripts { });
    sane-weather = callPackage ./additional/sane-weather { };
    schlock = callPackage ./additional/schlock { };
    signal-desktop-from-src = callPackage ./additional/signal-desktop-from-src { };
    static-nix-shell = callPackage ./additional/static-nix-shell { };
    sublime-music-mobile = callPackage ./additional/sublime-music-mobile { };
    swaylock-mobile = callPackage ./additional/swaylock-mobile { };
    swaylock-plugin = callPackage ./additional/swaylock-plugin { };
    sxmo_swaylock = callPackage ./additional/sxmo_swaylock { };
    sxmo-utils = callPackage ./additional/sxmo-utils { };
    sysvol = callPackage ./additional/sysvol { };
    tow-boot-pinephone = callPackage ./additional/tow-boot-pinephone { };
    tree-sitter-nix-shell = callPackage ./additional/tree-sitter-nix-shell { };
    trivial-builders = lib.recurseIntoAttrs (callPackage ./additional/trivial-builders { });
    wvkbd-mk = callPackage ./additional/wvkbd-mk { };
    inherit (trivial-builders)
      copyIntoOwnPackage
      linkIntoOwnPackage
      rmDbusServices
      rmDbusServicesInPlace
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
    # alsa-project = unpatched.alsa-project.overrideScope (sself: ssuper: {
    #   alsa-ucm-conf = sself.callPackage ./additional/alsa-ucm-conf-sane { inherit (ssuper) alsa-ucm-conf; };
    # });

    browserpass = callPackage ./patched/browserpass { inherit (unpatched) browserpass; };

    # mozilla keeps nerfing itself and removing configuration options
    firefox-unwrapped = callPackage ./patched/firefox-unwrapped { inherit (unpatched) firefox-unwrapped; };

    gocryptfs = callPackage ./patched/gocryptfs { inherit (unpatched) gocryptfs; };

    helix = callPackage ./patched/helix { inherit (unpatched) helix; };

    # ibus = callPackage ./patched/ibus { inherit (unpatched) ibus; };

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
    # "additional" packages only get added if their version is newer than upstream
    // (lib.mapAttrs
      (pname: _pkg: if unpatched ? "${pname}" && unpatched."${pname}" ? version && lib.versionAtLeast unpatched."${pname}".version final'.sane."${pname}".version  then
        unpatched."${pname}"
      else
        final'.sane."${pname}"
      )
      sane-additional
    )
  ;
in sane-overlay
