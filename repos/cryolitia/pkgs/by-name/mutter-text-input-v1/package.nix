{
  gnome,
  fetchpatch,
  stdenv,
}:

gnome.mutter.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches or [ ] ++ [
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/3751.patch";
      hash = "sha256-lSNmhM5T95hgblgvJLA/yxotKcjXxnKwlirKw+34ELU=";
    })
  ];
  meta = oldAttrs.meta // {
    description = "GNOME mutter with https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/3751";
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
})
