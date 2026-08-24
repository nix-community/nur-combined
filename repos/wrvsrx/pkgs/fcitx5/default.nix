{
  fcitx5,
  fetchpatch,
}:
fcitx5.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/fcitx5/compare/5.1.21..5.1.21+waylandim-flush-v1.diff";
      hash = "sha256-fb+iPkBetRJkNpZaHkEMubWSa4EsTuCAudLfPYRdOgo=";
    })
  ];
})
