{ lib, callPackage, darwin, fetchpatch, imagemagick, imagemagick7, sources
, stdenv, xorg, llvmPackages_6, srcRepo ? true }:

let
  mkEmacs = args:
    let
      commonArgs = {
        inherit (darwin.apple_sdk.frameworks) AppKit GSS ImageIO;
        inherit srcRepo;
        gconf = null;
      } // (lib.optionalAttrs stdenv.isDarwin darwinArgs);

      darwinArgs = {
        acl = null;
        alsaLib = null;
        gpm = null;
      };
    in callPackage ./generic.nix (commonArgs // args);

  emacs26 = mkEmacs {
    inherit imagemagick;

    harfbuzz = null;
    libXaw = xorg.libXaw;
    Xaw3d = null;
    jansson = null;

    src = sources.emacs-26_3;
    version = "26.3";

    patches = [
      ./clean-env.patch
      ./tramp-detect-wrapped-gvfsd.patch
      (fetchpatch {
        name = "multicolor-font.diff";
        url =
          "https://gist.githubusercontent.com/aatxe/260261daf70865fbf1749095de9172c5/raw/214b50c62450be1cbee9f11cecba846dd66c7d06/patch-multicolor-font.diff";
        sha256 = "0a8zzf8cmjykk1gznih500p2m44ldp07dqb4l4fmp6iv6havjs1k";
      })
    ];
  };

  emacs27 = mkEmacs {
    gpm = null;
    imagemagick = imagemagick7;
    libXaw = xorg.libXaw;
    Xaw3d = null;

    src = sources.emacs-master;
    version = "27.0.50";

    patches = [ ./clean-env-27.patch ./tramp-detect-wrapped-gvfsd.patch ];
  };

  emacs27-lucid = mkEmacs {
    imagemagick = imagemagick7;
    libXaw = xorg.libXaw;
    withNS = false;
    withX = true;
    withGTK2 = false;
    withGTK3 = false;

    src = sources.emacs-master;
    version = "27.0.50";

    patches = [ ./clean-env-27.patch ./tramp-detect-wrapped-gvfsd.patch ];
  };
in {
  inherit emacs26 emacs27 emacs27-lucid;

  emacsMacport = callPackage ./macport.nix {
    inherit (darwin.apple_sdk.frameworks)
      AppKit Carbon Cocoa IOKit OSAKit Quartz QuartzCore WebKit ImageCaptureCore
      GSS ImageIO;

    stdenv = if stdenv.cc.isClang then llvmPackages_6.stdenv else stdenv;
  };
}
