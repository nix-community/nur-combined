{
  fcitx5,
  fetchpatch,
}:
fcitx5.overrideAttrs (old: {
  patched = (old.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/fcitx5/compare/5.1.21..5.1.21+wayland-flush.diff";
      hash = "sha256-CT+CuuFTfSJtRRoyP2nx/G3UIBYFsG4k4BTw1gPMECM=";
    })
  ];
})
