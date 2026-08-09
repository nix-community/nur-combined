{
  neovim-unwrapped,
  fetchpatch,
}:
neovim-unwrapped.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/neovim/commit/162aee2e95ffaea1df409698e556a7c4fe0d8647.patch";
      hash = "sha256-p3nG4RNx7BdENGJu6zdr9sDKXKde9eSVDKWIW198Wac=";
    })
  ];
})
