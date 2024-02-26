{
  lib,
  source,
  emacs,
}:
emacs.overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "emacs-plus";
    name = "${finalAttrs.pname}-${prevAttrs.version}";
    patches = (prevAttrs.patches or [ ]) ++ [
      "${source.src}/patches/emacs-${lib.versions.major prevAttrs.version}/*"
    ];

    configureFlags = (prevAttrs.configureFlags or [ ]) ++ [
      (lib.withFeatureAs true "xml2" "yes")
      (lib.withFeatureAs true "gnutls" "yes")
    ];

    meta = prevAttrs.meta // {
      platforms = lib.platforms.darwin;
      # fail to patch on emacs28
      broken = lib.versionOlder prevAttrs.version "29";
    };
  }
)
