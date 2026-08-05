{
  neovim-unwrapped,
  fetchpatch,
}:
neovim-unwrapped.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/neovim/compare/v0.12.4...lsp-single-line-folds-nvim-0.12.4-v6.diff";
      hash = "sha256-vNE0O/kcOP8EnW73FIqF14MR2X/eU656wi6asSsaQsY=";
    })
  ];
})
