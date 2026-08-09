{
  neovim-unwrapped,
  fetchpatch,
}:
neovim-unwrapped.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/neovim/compare/deffa9f71...lsp-nested-folds-nvim-0.12.4-v1.diff";
      hash = "sha256-p3nG4RNx7BdENGJu6zdr9sDKXKde9eSVDKWIW198Wac=";
    })
  ];
})
