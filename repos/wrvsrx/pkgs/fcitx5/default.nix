{
  fcitx5,
  fetchpatch,
}:
fcitx5.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/fcitx5/compare/5.1.22..5.1.22+wayland-flush.diff";
      hash = "sha256-KrTi6Vhzr9xrs9MLdvFP3W6Sj47pZf/kz7yh0kuzPHU=";
    })
  ];
})
