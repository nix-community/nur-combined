{
  fcitx5,
  fetchpatch,
}:
fcitx5.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      # https://github.com/wrvsrx/fcitx5/compare/5.1.21..5.1.21+wayland-flush-v2.diff
      url = "https://github.com/wrvsrx/fcitx5/compare/5.1.21..5.1.21+wayland-flush-v3.diff";
      hash = "sha256-WHmtzopPzilHwyLzBKRMeF2UDWmbdanF9bVxZtk93G8=";
    })
  ];
})
