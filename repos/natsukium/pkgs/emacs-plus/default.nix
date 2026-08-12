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
    emacsAtLeast = lib.versionAtLeast prevAttrs.version;
  in
  {
    pname = "emacs-plus";
    name = "${finalAttrs.pname}-${prevAttrs.version}";

    patches =
      (prevAttrs.patches or [ ])
      ++ map (p: "${source.src}/patches/emacs-${emacsMajorVersion}/${p}") (
        [
          "round-undecorated-frame.patch"
          "system-appearance.patch"
        ]
        ++ lib.optional (emacsOlder "30") "no-frame-refocus-cocoa.patch"
        # upstream emacs 31 no longer needs the window role workaround
        ++ lib.optional (emacsOlder "31") "fix-window-role.patch"
        # x-colors is dumped in a headless builder and ends up with a truncated
        # color list, so refresh it when the display becomes available
        ++ lib.optional (emacsAtLeast "30") "fix-ns-x-colors.patch"
        # macOS 26 (Tahoe) scrolling lag; merged upstream into emacs 31
        ++ lib.optional (emacsAtLeast "30" && emacsOlder "31") "fix-macos-tahoe-scrolling.patch"
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
