{
  neovim-unwrapped,
  fetchpatch,
}:
neovim-unwrapped.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      # lsp-single-line-folds-nvim-0.12.4-v1
      url = "https://github.com/wrvsrx/neovim/commit/4609564713348cbdd85852d46d2f10655e0ac54d.patch";
      hash = "sha256-Q6e+Axx3ZZYje39gj0tgjwsMfxq99OXwPvfCcaIzO4s=";
    })
  ];
})
