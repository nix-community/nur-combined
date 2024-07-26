{ fetchpatch, ... }:

_final: prev: {
  none-ls-nvim = prev.none-ls-nvim.overrideAttrs (oa: {
    patches = (oa.patches or [ ]) ++ [
      # https://github.com/nvimtools/none-ls.nvim/pull/163
      (fetchpatch {
        name = "fix-get-root-directory.patch";
        url = "https://github.com/nvimtools/none-ls.nvim/commit/2cde745aadc2c36f6860a77a556494870675771a.patch";
        hash = "sha256-BtIjrT6ME2mR/5Ez9h+6r+fy0jYkBkw6/A9NConKRVs=";
      })
    ];
  });
}
