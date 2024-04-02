{ fetchpatch, ... }:

_final: prev: {
  gruvbox-nvim = prev.gruvbox-nvim.overrideAttrs (oa: {
    patches = (oa.patches or [ ]) ++ [
      # https://github.com/ellisonleao/gruvbox.nvim/pull/319
      (fetchpatch {
        name = "expose-color-palette.patch";
        url = "https://github.com/ellisonleao/gruvbox.nvim/commit/07a493ba4f8b650aab9ed9e486caa89822be0996.patch";
        hash = "sha256-iGwt8qIHe2vaiAUcpaUxyGlM472F89vobTdQ7CF/H70=";
      })
    ];
  });
}
