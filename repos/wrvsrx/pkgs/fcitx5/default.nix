{
  fcitx5,
  fetchpatch,
}:
fcitx5.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      # https://github.com/fcitx/fcitx5/pull/1667
      url = "https://github.com/wrvsrx/fcitx5/compare/5.1.21..5.1.21+waylandim-teardown-v1.diff";
      hash = "sha256-wJrQWdjO1g22CJExR4ti4pgpGPavIsVq9xQyHge+vGY=";
    })
  ];
})
