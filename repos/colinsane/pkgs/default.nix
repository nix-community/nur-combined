# this supports being used as an overlay or in a standalone context
# - if overlay, invoke as `(final: prev: import ./. { inherit final; pkgs = prev; })`
# - if standalone: `import ./. { inherit pkgs; }`
#
# using the correct invocation is critical if any packages mentioned here are
# additionally patched elsewhere
#
{ pkgs ? import ./additional/nixpkgs { }, final ? null }:
let
  lib = pkgs.lib;
  unpatched = pkgs;
  final' = if final != null then final else pkgs.extend (_: _: sane-overlay);
  sane-additional = with final'; {
    sane-data = import ../modules/data { inherit lib sane-lib; };
    sane-lib = import ../modules/lib final';

    ### ADDITIONAL PACKAGES
    alsa-ucm-pinephone-manjaro = callPackage ./additional/alsa-ucm-pinephone-manjaro { };
    alsa-ucm-pinephone-pmos = callPackage ./additional/alsa-ucm-pinephone-pmos { };
    blast-ugjka = callPackage ./additional/blast-ugjka { };
    bootpart-uefi-x86_64 = callPackage ./additional/bootpart-uefi-x86_64 { };
    cargoDocsetHook = callPackage ./additional/cargo-docset/hook.nix { };
    chatty-latest = callPackage ./additional/chatty-latest { };
    clightning-sane = callPackage ./additional/clightning-sane { };
    codemadness-frontends = callPackage ./additional/codemadness-frontends { };
    codemadness-frontends_0_6 = codemadness-frontends.v0_6;
    crust-firmware-pinephone = callPackage ./additional/crust-firmware-pinephone { };
    curlftpfs-sane = callPackage ./additional/curlftpfs-sane { };
    depthcharge-tools = callPackage ./additional/depthcharge-tools { };
    eg25-control = callPackage ./additional/eg25-control { };
    eg25-manager = callPackage ./additional/eg25-manager { };
    fastcluster = callPackage ./additional/fastcluster { };
    feeds = lib.recurseIntoAttrs (callPackage ./additional/feeds { });
    feedsearch-crawler = callPackage ./additional/feedsearch-crawler { };
    firefox-extensions = lib.recurseIntoAttrs (callPackage ./additional/firefox-extensions { });
    flare-signal-nixified = callPackage ./additional/flare-signal-nixified { };
    fractal-nixified = callPackage ./additional/fractal-nixified { };
    geary-gtk4 = callPackage ./additional/geary-gtk4 { };
    geoclue-ols = callPackage ./additional/geoclue-ols { };
    gopass-native-messaging-host = callPackage ./additional/gopass-native-messaging-host { };
    gpodder-adaptive = callPackage ./additional/gpodder-adaptive { };
    gpodder-adaptive-configured = callPackage ./additional/gpodder-configured {
      gpodder = final'.gpodder-adaptive;
    };
    gpodder-configured = callPackage ./additional/gpodder-configured { };
    gps-share = callPackage ./additional/gps-share { };
    hackgregator = callPackage ./additional/hackgregator { };
    jellyfin-media-player-qt6 = callPackage ./additional/jellyfin-media-player-qt6 { };
    koreader-from-src = callPackage ./additional/koreader-from-src { };
    landlock-sandboxer = callPackage ./additional/landlock-sandboxer { };
    ldd-aarch64 = callPackage ./additional/ldd-aarch64 { };
    lemoa = callPackage ./additional/lemoa { };
    lemmy-lemonade = callPackage ./additional/lemonade { };  # XXX: nixpkgs already has a `lemonade` pkg
    lgtrombetta-compass = callPackage ./additional/lgtrombetta-compass { };
    libdng = callPackage ./additional/libdng { };
    libfuse-sane = callPackage ./additional/libfuse-sane { };
    libmegapixels = callPackage ./additional/libmegapixels { };
    lightdm-mobile-greeter = callPackage ./additional/lightdm-mobile-greeter { };
    linux-exynos5-mainline = callPackage ./additional/linux-exynos5-mainline { };
    linux-firmware-megous = callPackage ./additional/linux-firmware-megous { };
    # XXX: eval error: need to port past linux_6_4
    # linux-manjaro = callPackage ./additional/linux-manjaro { };
    linux-megous = callPackage ./additional/linux-megous { };
    linux-postmarketos-allwinner = callPackage ./additional/linux-postmarketos-allwinner { };
    linux-postmarketos-exynos5 = callPackage ./additional/linux-postmarketos-exynos5 { };
    listparser = callPackage ./additional/listparser { };
    mcg = callPackage ./additional/mcg { };
    megapixels-next = callPackage ./additional/megapixels-next { };
    mobile-nixos = callPackage ./additional/mobile-nixos { };
    modemmanager-split = callPackage ./additional/modemmanager-split { };
    mx-sanebot = callPackage ./additional/mx-sanebot { };
    networkmanager-split = callPackage ./additional/networkmanager-split { };
    newsflash-nixified = callPackage ./additional/newsflash-nixified { };
    nixpkgs = callPackage ./additional/nixpkgs {
      localSystem = stdenv.buildPlatform.system;
      system = stdenv.hostPlatform.system;
    };
    nixpkgs-staging = nixpkgs.override { variant = "staging"; };
    nixpkgs-next = nixpkgs.override { variant = "staging-next"; };
    nixpkgs-wayland = callPackage ./additional/nixpkgs-wayland { };
    opencellid = callPackage ./additional/opencellid { };
    pa-dlna = callPackage ./additional/pa-dlna { };
    peerswap = callPackage ./additional/peerswap { };
    phog = callPackage ./additional/phog { };
    pipeline = callPackage ./additional/pipeline { };
    pyln-bolt7 = callPackage ./additional/pyln-bolt7 { };
    pyln-client = callPackage ./additional/pyln-client { };
    pyln-proto = callPackage ./additional/pyln-proto { };
    qmkPackages = recurseIntoAttrs (callPackage ./additional/qmk-packages { });
    rtl8723cs-firmware = callPackage ./additional/rtl8723cs-firmware { };
    rtl8723cs-wowlan = callPackage ./additional/rtl8723cs-wowlan { };
    sane-backgrounds = callPackage ./additional/sane-backgrounds { };
    sane-cast = callPackage ./additional/sane-cast { };
    sane-die-with-parent = callPackage ./additional/sane-die-with-parent { };
    sane-kernel-tools = lib.recurseIntoAttrs (callPackage ./additional/sane-kernel-tools { });
    sane-nix-files = callPackage ./additional/sane-nix-files { };
    sane-open = callPackage ./additional/sane-open { };
    sane-screenshot = callPackage ./additional/sane-screenshot { };
    sane-scripts = lib.recurseIntoAttrs (callPackage ./additional/sane-scripts { });
    sane-sysload = callPackage ./additional/sane-sysload { };
    sane-weather = callPackage ./additional/sane-weather { };
    sanebox = callPackage ./additional/sanebox { };
    schlock = callPackage ./additional/schlock { };
    signal-desktop-from-src = callPackage ./additional/signal-desktop-from-src { };
    sofacoustics = lib.recurseIntoAttrs (callPackage ./additional/sofacoustics { });
    sops-nix = callPackage ./additional/sops-nix { };
    static-nix-shell = callPackage ./additional/static-nix-shell { };
    sublime-music-mobile = callPackage ./additional/sublime-music-mobile { };
    swaylock-mobile = callPackage ./additional/swaylock-mobile { };
    swaylock-plugin = callPackage ./additional/swaylock-plugin { };
    sxmo_swaylock = callPackage ./additional/sxmo_swaylock { };
    sxmo-suspend = callPackage ./additional/sxmo-suspend { };
    syshud = callPackage ./additional/syshud { };
    tow-boot-pinephone = callPackage ./additional/tow-boot-pinephone { };
    tree-sitter-nix-shell = callPackage ./additional/tree-sitter-nix-shell { };
    trivial-builders = lib.recurseIntoAttrs (callPackage ./additional/trivial-builders { });
    u-boot-pinephone = callPackage ./additional/u-boot-pinephone { };
    uassets = callPackage ./additional/uassets { };
    uninsane-dot-org = callPackage ./additional/uninsane-dot-org { };
    wvkbd-mk = callPackage ./additional/wvkbd-mk { };
    inherit (trivial-builders)
      copyIntoOwnPackage
      deepLinkIntoOwnPackage
      linkBinIntoOwnPackage
      linkIntoOwnPackage
      rmDbusServices
      rmDbusServicesInPlace
      runCommandLocalOverridable
    ;
    unftp = callPackage ./additional/unftp { };
    zecwallet-light-cli = callPackage ./additional/zecwallet-light-cli { };

    # packages i haven't used for a while, may or may not still work
    # fluffychat-moby = callPackage ./additional/fluffychat-moby { };
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

    #### short-term build fixes
    clightning = unpatched.clightning.override {
      # XXX(2024-07-07): build fails with default `python3`
      python3 = pkgs.python311;
    };

    #### long-term patching
    browserpass = callPackage ./patched/browserpass { inherit (unpatched) browserpass; };
    # mozilla keeps nerfing itself and removing configuration options
    firefox-unwrapped = callPackage ./patched/firefox-unwrapped { inherit (unpatched) firefox-unwrapped; };
    # gocryptfs = callPackage ./patched/gocryptfs { inherit (unpatched) gocryptfs; };
    helix = callPackage ./patched/helix { inherit (unpatched) helix; };
    # ibus = callPackage ./patched/ibus { inherit (unpatched) ibus; };
    # modemmanager = callPackage ./patched/modemmanager { inherit (unpatched) modemmanager; };
    passt = import ./patched/passt { inherit (unpatched) passt; };
    playerctl = unpatched.playerctl.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (fetchpatch {
          # playerctl, when used as a library, doesn't expect its user to `unref` it inside a glib signal.
          # nwg-panel does this though, and then segfaults.
          # playerctl project looks dead as of 2024/06/19, no hope for upstreaming this.
          # TODO: consider removing this if nwg-panel code is changed to not trigger this.
          # - <https://github.com/nwg-piotr/nwg-panel/issues/233>
          name = "dbus_name_owner_changed_callback: acquire a ref on the manager before using it";
          url = "https://git.uninsane.org/colin/playerctl/commit/bbcbbe4e03da93523b431ffee5b64e10b17b4f9f.patch";
          hash = "sha256-l/w+ozga8blAB2wtEd1SPBE6wpHNXWk7NrOL7x10oUI=";
        })
      ];
    });
  };
  sane-overlay = {
    sane = lib.recurseIntoAttrs (sane-additional // sane-patched);
  }
    # patched packages always override anything:
    // sane-patched
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
