{ meson, fetchpatch }:
meson.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    # https://github.com/mesonbuild/meson/pull/14178
    (fetchpatch {
      url = "https://github.com/wrvsrx/meson/compare/tag_fix-mformat-9%5E...tag_fix-mformat-9.patch";
      hash = "sha256-AR+c9zakQO5oEqmOeoi859K+9qXyRwgMjJr+Uq1l2IA=";
    })
  ];
})
