{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, unpatched ? pkgs }:
let

  pythonPackagesOverlay = py-final: py-prev: import ./python-packages {
    inherit (py-final) callPackage;
  };
  # this scope ensures that my packages can all take each other as inputs,
  # even when evaluated bare (i.e. outside of an overlay)
  sane = lib.makeScope pkgs.newScope (self: with self; {
    sane-data = import ../modules/data { inherit lib; };
    sane-lib = import ../modules/lib pkgs;

    ### ADDITIONAL PACKAGES
    bootpart-uefi-x86_64 = callPackage ./additional/bootpart-uefi-x86_64 { };
    browserpass-extension = callPackage ./additional/browserpass-extension { };
    cargo-docset = callPackage ./additional/cargo-docset { };
    cargoDocsetHook = callPackage ./additional/cargo-docset/hook.nix { };
    feeds = lib.recurseIntoAttrs (callPackage ./additional/feeds { });
    gopass-native-messaging-host = callPackage ./additional/gopass-native-messaging-host { };
    gpodder-configured = callPackage ./additional/gpodder-configured { };
    lightdm-mobile-greeter = callPackage ./additional/lightdm-mobile-greeter { };
    linux-megous = callPackage ./additional/linux-megous { };
    mx-sanebot = callPackage ./additional/mx-sanebot { };
    rtl8723cs-firmware = callPackage ./additional/rtl8723cs-firmware { };
    sane-scripts = callPackage ./additional/sane-scripts { };
    static-nix-shell = callPackage ./additional/static-nix-shell { };
    sublime-music-mobile = callPackage ./additional/sublime-music-mobile { };
    tow-boot-pinephone = callPackage ./additional/tow-boot-pinephone { };

    # packages i haven't used for a while, may or may not still work
    # fluffychat-moby = callPackage ./additional/fluffychat-moby { };
    # fractal-latest = callPackage ./additional/fractal-latest { };
    # kaiteki = callPackage ./additional/kaiteki { };
    # tokodon = libsForQt5.callPackage ./additional/tokodon { };

    # old rpi packages that may or may not still work
    # bootpart-tow-boot-rpi-aarch64 = callPackage ./additional/bootpart-tow-boot-rpi-aarch64 { };
    # bootpart-u-boot-rpi-aarch64 = callPackage ./additional/bootpart-u-boot-rpi-aarch64 { };
    # tow-boot-rpi4 = callPackage ./additional/tow-boot-rpi4 { };
    # patch rpi uboot with something that fixes USB HDD boot
    # ubootRaspberryPi4_64bit = callPackage ./additional/ubootRaspberryPi4_64bit { };

    # provided by nixpkgs patch or upstream PR
    # splatmoji = callPackage ./additional/splatmoji { };


    ### PATCHED PACKAGES

    # XXX: the `inherit`s here are because:
    # - pkgs.callPackage draws from the _final_ package set.
    # - unpatched.XYZ draws (selectively) from the _unpatched_ package set.
    # see <overlays/pkgs.nix>
    browserpass = callPackage ./patched/browserpass { inherit (unpatched) browserpass; };

    # mozilla keeps nerfing itself and removing configuration options
    firefox-unwrapped = callPackage ./patched/firefox-unwrapped { inherit (unpatched) firefox-unwrapped; };

    gocryptfs = callPackage ./patched/gocryptfs { inherit (unpatched) gocryptfs; };

    # jackett doesn't allow customization of the bind address: this will probably always be here.
    jackett = callPackage ./patched/jackett { inherit (unpatched) jackett; };

    lemmy-server = callPackage ./patched/lemmy-server { inherit (unpatched) lemmy-server; };


    ### PYTHON PACKAGES
    pythonPackagesExtensions = (unpatched.pythonPackagesExtensions or []) ++ [
      pythonPackagesOverlay
    ];
    # when this scope's applied as an overlay pythonPackagesExtensions is propagated as desired.
    # but when freestanding (e.g. NUR), it never gets plumbed into the outer pkgs, so we have to do that explicitly.
    python3 = unpatched.python3.override {
      packageOverrides = pythonPackagesOverlay;
    };
  });
in sane.packages sane
