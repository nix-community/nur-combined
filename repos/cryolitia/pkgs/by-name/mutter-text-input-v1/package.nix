{
  gnome,
  fetchpatch,
  stdenv,
}:

gnome.mutter.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches or [ ] ++ [
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/mutter/-/commit/fd488c5a4a24345071edefe423a9591e67f5636b.patch";
      hash = "sha256-xEaGvTBdQBsB7s5H+LRJ6LoPPfh3VAz2hz074WjSR84=";
    })
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/mutter/-/commit/2a94e19b00434fe4d7ab858a6cdcff6364f6e408.patch";
      hash = "sha256-pRd+fq+7Y2TVFBJCvtCLm8Rsviim6KdTEhGTiI9DDjY=";
    })
  ];
  meta = oldAttrs.meta // {
    description = "GNOME mutter with https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/3751";
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
})
