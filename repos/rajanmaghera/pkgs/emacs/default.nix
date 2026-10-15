{
  emacs31-pgtk,
  fetchpatch,
  stdenv,
  ...
}:
if stdenv.hostPlatform.isDarwin then
  (emacs31-pgtk.overrideAttrs (old: {
    pname = old.pname + "-homebrew-patches";
    withXwidgets = true;
    withNativecomp = true;
    patches = (old.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/refs/heads/master/patches/emacs-31/fix-ns-scroll-crash.patch";
        sha256 = "sha256-syC9un5Vy1+bmBWIc+TEwTCM/nfPIxd4IhWYdEfP4qE=";
      })
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/refs/heads/master/patches/emacs-31/fix-ns-x-colors.patch";
        sha256 = "sha256-oe3DFgEXwp0cZJl+ufWqTonaeWSliikTRsVDNbcy4Yw=";
      })
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/refs/heads/master/patches/emacs-31/round-undecorated-frame.patch";
        sha256 = "sha256-KCMEvJzN1OkwFYoMLpZghvdeoO1Ckcxk3Mo19YAf850=";
      })
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/refs/heads/master/patches/emacs-31/system-appearance.patch";
        sha256 = "sha256-4+2U+4+2tpuaThNJfZOjy1JPnneGcsoge9r+WpgNDko=";
      })
    ];
  }))
else
  emacs31-pgtk
