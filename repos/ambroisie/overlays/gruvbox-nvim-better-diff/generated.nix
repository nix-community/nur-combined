{ ... }:

_final: prev: {
  gruvbox-nvim = prev.gruvbox-nvim.overrideAttrs (oa: {
    patches = (oa.patches or [ ]) ++ [
      # Inspired by https://github.com/ellisonleao/gruvbox.nvim/pull/291
      ./colours.patch
    ];
  });
}
