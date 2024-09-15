{
  gnome-shell,
  fetchpatch,
  stdenv,
}:

gnome-shell.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches ++ [
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/3318.patch";
      hash = "sha256-MWeEaTeL9wkFW/MolG/N8+vMkEi9KTKdwJqqSaNzxF8=";
    })
  ];
  meta = oldAttrs.meta // {
    description = "GNOME shell with https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/3318";
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
})
