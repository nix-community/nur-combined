{
  callPackage,
  buildVimPlugin,
  ...
}: {
  gh-actions-nvim = callPackage ./gh-actions-nvim.nix {
    inherit buildVimPlugin;
  };
}
