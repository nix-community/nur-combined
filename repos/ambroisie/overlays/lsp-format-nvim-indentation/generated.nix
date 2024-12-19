{ fetchpatch, ... }:

_final: prev: {
  lsp-format-nvim = prev.lsp-format-nvim.overrideAttrs (oa: {
    patches = (oa.patches or [ ]) ++ [
      # https://github.com/lukas-reineke/lsp-format.nvim/issues/94
      (fetchpatch {
        name = "use-effective-indentation";
        url = "https://github.com/liskin/lsp-format.nvim/commit/3757ac443bdf5bd166673833794553229ee8d939.patch";
        hash = "sha256-Dv+TvXrU/IrrPxz2MSPbLmRxch+qkHbI3AyFMj/ssDk=";
      })
    ];
  });
}
