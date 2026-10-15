# Emacs with the macOS patches from d12frosted/homebrew-emacs-plus.
#
# Follows whatever Emacs the channel ships (30 on nixos-26.05, 31 on unstable)
# and picks the matching patch set, mirroring the emacs-plus@30 / @31 formulae.
#
#   Linux:  plain emacs-pgtk (the patches are Cocoa-only).
#   Darwin: the Cocoa (NS) build + emacs-plus patches. A pgtk build on macOS
#           would never compile nsterm.m, so the patches would do nothing.
{
  lib,
  stdenv,
  emacs,
  emacs-pgtk,
  fetchFromGitHub,
}:
let
  # To update: bump rev, set hash = lib.fakeHash, build, paste the real hash.
  emacs-plus = fetchFromGitHub {
    owner = "d12frosted";
    repo = "homebrew-emacs-plus";
    rev = "388d0060a56b41c7aae70da3725c5536fa54547a";
    sparseCheckout = [ "patches" ];
    hash = "sha256-rSyDMYGrttvdzSRV//k5dB3kyMViICXDUPMbPmGq6EE=";
  };

  # Same patches, same order as the `local_patch` lines in
  # Formula/emacs-plus@<major>.rb at the pinned rev.
  patchSets = {
    "30" = [
      "fix-window-role"
      "system-appearance"
      "round-undecorated-frame"
      "fix-macos-tahoe-scrolling"
      "fix-ns-x-colors"
    ];
    "31" = [
      "fix-ns-x-colors"
      "system-appearance"
      "round-undecorated-frame"
      "fix-ns-scroll-crash"
    ];
  };

  major = lib.versions.major emacs.version;
  patchNames = patchSets.${major} or null;
  supported = patchNames != null;
in
if !stdenv.hostPlatform.isDarwin then
  emacs-pgtk
else
  (emacs.override {
    withNS = true;
    withXwidgets = true;
    withNativeCompilation = true;
  }).overrideAttrs
    (old: {
      pname = old.pname + "-homebrew-patches";
      patches =
        (old.patches or [ ])
        ++ lib.optionals supported (
          map (name: "${emacs-plus}/patches/emacs-${major}/${name}.patch") patchNames
        );
      meta = old.meta // {
        description = "GNU Emacs with the homebrew-emacs-plus macOS patches";
        # New Emacs major with no patch set yet: skipped by CI instead of failing.
        broken = (old.meta.broken or false) || !supported;
      };
    })
