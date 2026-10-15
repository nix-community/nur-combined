{
  emacs30-pgtk,
  fetchpatch,
  stdenv,
  ...
}:
if stdenv.hostPlatform.isDarwin then
  (emacs30-pgtk.overrideAttrs (old: {
    pname = old.pname + "-homebrew-patches";
    withXwidgets = true;
    withNativecomp = true;
    patches = (old.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/refs/heads/master/patches/emacs-30/fix-macos-tahoe-scrolling.patch";
        sha256 = "sha256-Hf9oZ5ImBnxTLa6yS02UDzBEgJEGAwNq/svJ3S35uKw=";
      })
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/refs/heads/master/patches/emacs-30/fix-ns-x-colors.patch";
        sha256 = "sha256-oe3DFgEXwp0cZJl+ufWqTonaeWSliikTRsVDNbcy4Yw=";
      })
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/refs/heads/master/patches/emacs-28/fix-window-role.patch";
        sha256 = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
      })
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/refs/heads/master/patches/emacs-30/round-undecorated-frame.patch";
        sha256 = "sha256-fesZ0H3LO6T2AiRV8ASozKxZBpvVzwLEcLDy6rctR6c=";
      })
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/refs/heads/master/patches/emacs-30/system-appearance.patch";
        sha256 = "sha256-3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=";

      })
    ];
  }))
else
  emacs30-pgtk
