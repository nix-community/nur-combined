{
  fcitx5-rime,
  fetchpatch,
  librime,
}:
let
  fcitx5-rime' = fcitx5-rime.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://github.com/wrvsrx/fcitx5-rime/compare/tag_support-set-data-dir-via-xdg-3%5E..tag_support-set-data-dir-via-xdg-3.patch";
        hash = "sha256-awUPuj64gu58MyjpXoxmnJX9FiQE5t+dCh3kwDXVgBc=";
      })
      ./restore-ascii.patch
    ];
  });
in
fcitx5-rime'.override {
  rimeDataPkgs = [ ];
  inherit librime;
}
