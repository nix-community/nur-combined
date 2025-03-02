{
  fcitx5-rime,
  fetchpatch,
  librime,
}:
let
  fcitx5-rime' = fcitx5-rime.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (fetchpatch {
        # https://github.com/wrvsrx/fcitx5-rime/tree/tag_support-set-data-dir-via-xdg-2
        url = "https://github.com/wrvsrx/fcitx5-rime/compare/fd8bf83dcd731eacd095f8b01cd2ea1f9e9aa429...80955b33e33cb85de9e33052d8e42f8d6822613b.patch";
        hash = "sha256-Pgz/+3XkAxbwpIS3cnmfaAz9eHcrNFqSq8n8EkSiz1Q=";
      })
      ./restore-ascii.patch
    ];
  });
in
fcitx5-rime'.override {
  rimeDataPkgs = [ ];
  inherit librime;
}
