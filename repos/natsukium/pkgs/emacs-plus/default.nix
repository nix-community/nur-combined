{
  lib,
  source,
  emacs,
}:

emacs.overrideAttrs (
  finalAttrs: prevAttrs:
  let
    emacsMajorVersion = lib.versions.major prevAttrs.version;
    emacsOlder = lib.versionOlder prevAttrs.version;
  in
  {
    pname = "emacs-plus";
    name = "${finalAttrs.pname}-${prevAttrs.version}";

    patches =
      (prevAttrs.patches or [ ])
      ++ map (p: "${source.src}/patches/emacs-${emacsMajorVersion}/${p}") (
        [
          "fix-window-role.patch"
          "poll.patch"
          "round-undecorated-frame.patch"
          "system-appearance.patch"
        ]
        ++ lib.optional (emacsOlder "30") "no-frame-refocus-cocoa.patch"
      );

    configureFlags = (prevAttrs.configureFlags or [ ]) ++ [
      (lib.withFeatureAs true "xml2" "yes")
      (lib.withFeatureAs true "gnutls" "yes")
    ];

    meta = prevAttrs.meta // {
      description = "A wide range of extra functionality over regular Emacs for macOS";
      homepage = "https://github.com/d12frosted/homebrew-emacs-plus";
      platforms = lib.platforms.darwin;
      # fail to patch on emacs28
      broken = emacsOlder "29";
    };
  }
)
