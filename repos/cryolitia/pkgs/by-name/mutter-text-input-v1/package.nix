{
  mutter,
  fetchpatch,
  stdenv,
}:

mutter.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches or [ ] ++ [
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/mutter/-/commit/6b9bbebbdc3a8b35f898a269227f36a36590359e.patch";
      hash = "sha256-0HhBMmkXkVJMd/1AL/0CRaYTJgN0Zc1LVWJVxhqVdhE=";
    })
  ];
  meta = oldAttrs.meta // {
    description = "GNOME mutter with https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/3751";
    broken = true || stdenv.buildPlatform != stdenv.hostPlatform;
  };
})
