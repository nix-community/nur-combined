{
  fcitx5,
  fetchpatch,
}:
fcitx5.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/fcitx5/compare/wayland-flush-5.1.21-v2^..wayland-flush-5.1.21-v2.diff";
      hash = "sha256-IOZFEhHVGTDe7Ut7NlrZEwbxzY7a5IBlgMsTu/8JUT0=";
    })
  ];
})
