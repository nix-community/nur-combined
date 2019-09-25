{ callPackage, darwin, fetchpatch, imagemagick, imagemagick7, sources, xorg }:

let
  mkEmacs = callPackage ./generic.nix;

  emacs26 = mkEmacs {
    inherit (darwin.apple_sdk.frameworks) AppKit GSS ImageIO;
    inherit imagemagick;

    acl      = null;
    alsaLib  = null;
    gconf    = null;
    gpm      = null;
    harfbuzz = null;
    libXaw   = xorg.libXaw;
    Xaw3d    = null;
    jansson  = null;

    src     = sources.emacs-26_3;
    version = "26.3";

    patches = [
      ./clean-env.patch
      ./tramp-detect-wrapped-gvfsd.patch
      (fetchpatch {
        name   = "multicolor-font.diff";
        url    = https://gist.githubusercontent.com/aatxe/260261daf70865fbf1749095de9172c5/raw/214b50c62450be1cbee9f11cecba846dd66c7d06/patch-multicolor-font.diff;
        sha256 = "0a8zzf8cmjykk1gznih500p2m44ldp07dqb4l4fmp6iv6havjs1k"; })
    ];
  };

  emacs27 = mkEmacs {
    inherit (darwin.apple_sdk.frameworks) AppKit GSS ImageIO;

    acl         = null;
    alsaLib     = null;
    gconf       = null;
    gpm         = null;
    imagemagick = imagemagick7;
    libXaw      = xorg.libXaw;
    Xaw3d       = null;

    src     = sources.emacs-master;
    version = "27.0.50";

    patches = [
      ./clean-env-27.patch
      ./tramp-detect-wrapped-gvfsd.patch
    ];
  };
in {
  inherit emacs26 emacs27;
}
