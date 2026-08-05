{
  neovim-unwrapped,
  fetchpatch,
}:
neovim-unwrapped.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      # lsp-single-line-folds-nvim-0.12.4-v4
      url = "https://github.com/wrvsrx/neovim/compare/68ea43cd0c...e1f13122e3.patch";
      hash = "sha256-pq/T9qcO6ht7bfQaJ86v38jYJUUvoDxYuTh+RIeiCh0=";
    })
  ];
})
