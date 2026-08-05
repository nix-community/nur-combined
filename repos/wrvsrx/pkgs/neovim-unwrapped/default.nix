{
  neovim-unwrapped,
  fetchpatch,
}:
neovim-unwrapped.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/neovim/compare/lsp-single-line-folds-nvim-0.12.4-v5~3..lsp-single-line-folds-nvim-0.12.4-v5.diff";
      hash = "sha256-H9WYT+3BsbtIKZOkxTlT2Y9fGWI5b2/ZW6SCtCu806c=";
    })
  ];
})
