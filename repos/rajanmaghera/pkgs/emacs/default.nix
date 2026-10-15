{
  lib,
  emacs-pgtk,
  fetchpatch,
  stdenv,
  ...
}:
let
  # Pin this to a commit instead of refs/heads/master, or the hashes
  # break whenever upstream edits a patch.
  rev = "refs/heads/master";
  homebrewPatch =
    path: hash:
    fetchpatch {
      url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/${rev}/patches/${path}";
      inherit hash;
    };

  # Keyed by Emacs major version. Lazy: only the selected list is ever evaluated.
  patchSets = {
    "30" = [
      (homebrewPatch "emacs-30/fix-macos-tahoe-scrolling.patch" "sha256-Hf9oZ5ImBnxTLa6yS02UDzBEgJEGAwNq/svJ3S35uKw=")
      (homebrewPatch "emacs-30/fix-ns-x-colors.patch" "sha256-oe3DFgEXwp0cZJl+ufWqTonaeWSliikTRsVDNbcy4Yw=")
      (homebrewPatch "emacs-28/fix-window-role.patch" "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=")
      (homebrewPatch "emacs-30/round-undecorated-frame.patch" "sha256-fesZ0H3LO6T2AiRV8ASozKxZBpvVzwLEcLDy6rctR6c=")
      (homebrewPatch "emacs-30/system-appearance.patch" "sha256-3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=")
    ];
    "31" = [
      (homebrewPatch "emacs-31/fix-ns-scroll-crash.patch" "sha256-syC9un5Vy1+bmBWIc+TEwTCM/nfPIxd4IhWYdEfP4qE=")
      (homebrewPatch "emacs-31/fix-ns-x-colors.patch" "sha256-oe3DFgEXwp0cZJl+ufWqTonaeWSliikTRsVDNbcy4Yw=")
      (homebrewPatch "emacs-31/round-undecorated-frame.patch" "sha256-KCMEvJzN1OkwFYoMLpZghvdeoO1Ckcxk3Mo19YAf850=")
      (homebrewPatch "emacs-31/system-appearance.patch" "sha256-4+2U+4+2tpuaThNJfZOjy1JPnneGcsoge9r+WpgNDko=")
    ];
  };

  major = lib.versions.major emacs-pgtk.version;
  selectedPatches = patchSets.${major} or null;
in
if !stdenv.hostPlatform.isDarwin then
  emacs-pgtk
else
  (emacs-pgtk.override {
    withXwidgets = true;
    withNativeCompilation = true;
  }).overrideAttrs
    (old: {
      pname = old.pname + "-homebrew-patches";
      patches = (old.patches or [ ]) ++ (if selectedPatches == null then [ ] else selectedPatches);
      # A new major version with no patch set yet: CI skips it instead of failing
      meta = old.meta // lib.optionalAttrs (selectedPatches == null) { broken = true; };
    })
