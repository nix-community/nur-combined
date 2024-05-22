{ fetchpatch, ... }:

_final: prev: {
  gruvbox-nvim = prev.gruvbox-nvim.overrideAttrs (oa: {
    patches = (oa.patches or [ ]) ++ [
      # https://github.com/ellisonleao/gruvbox.nvim/pull/319
      (fetchpatch {
        name = "add-Delimiter-highlight-group.patch";
        url = "https://github.com/ellisonleao/gruvbox.nvim/commit/20f90039564b293330bf97acc36dda8dd9e721a0.patch";
        hash = "sha256-it4SbgK/2iDVyvtXBfVW2YN9DqELfKsMkuCaunERGcE=";
      })
    ];
  });
}
