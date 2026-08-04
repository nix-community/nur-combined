{
  neovim-unwrapped,
  fetchpatch,
}:
neovim-unwrapped.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      # lsp-single-line-folds-nvim-0.12.4-v3
      url = "https://github.com/wrvsrx/neovim/commit/2435abd1fb.patch";
      hash = "sha256-eoP6oO/sN45KSlshvYzmXmMoM6+2MXIMsb5Cwv/LJOY=";
    })
  ];
})
