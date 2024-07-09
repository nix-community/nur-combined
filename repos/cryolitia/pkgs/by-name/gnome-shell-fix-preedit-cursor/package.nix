{
  gnome,
  fetchpatch,
  stdenv,
}:

gnome.gnome-shell.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches ++ [
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/gnome-shell/-/commit/c17f3aa64a264a5fec7d3c5f8d1e9415b60a55b4.patch";
      hash = "";
    })
  ];
  meta = oldAttrs.meta // {
    description = "GNOME shell with https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/3318";
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
})
