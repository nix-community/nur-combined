{
  neovim-unwrapped,
  fetchpatch,
}:
neovim-unwrapped.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      # lsp-single-line-folds-nvim-0.12.4-v4
      url = "https://github.com/wrvsrx/neovim/compare/lsp-single-line-folds-nvim-0.12.4-v4~2..lsp-single-line-folds-nvim-0.12.4-v4.diff";
      hash = "sha256-Vw/nY23NrWmsekI3MDgLqMvbIja6inX0wcuYrLOXLds=";
    })
  ];
})
