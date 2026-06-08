{ wineWowPackages }:

# Autodesk Fusion runner: wine-staging (wow64) plus the captionless-popup
# window-management patch Fusion needs on X11 window managers (the marking
# menu, browser flyouts and other borderless popups otherwise get managed by
# the WM and misbehave). The fix is rejected upstream (wine treats such
# windows as malformed), so it lives here.
#
# Unpinned on purpose: tracks the repo's nixpkgs. If a wine bump shifts the
# patched source, the build fails loudly rather than drifting silently.
wineWowPackages.staging.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./captionless-popups.patch ];

  # Heavy source build: keep CI out of it. ci.nix's isCacheable filters on
  # preferLocalBuild, so this is built locally and pushed to the cache.
  preferLocalBuild = true;
})
