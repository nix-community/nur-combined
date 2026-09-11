{
  fcitx5,
  fetchpatch,
}:
fcitx5.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      # https://github.com/wrvsrx/fcitx5/compare/5.1.21..5.1.21+wayland-flush-v2.diff
      url = "https://github.com/wrvsrx/fcitx5/compare/wayland-flush-v1^..wayland-flush-v1.diff";
      hash = "sha256-4Tog/pPK1fq+A3/UAjT8UpZ5xWCXN9r7k1xbeYK/xxU=";
    })
  ];
})
