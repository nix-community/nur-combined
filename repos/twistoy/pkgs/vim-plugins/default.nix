{
  callPackage,
  buildVimPlugin,
  ...
}: {
  gh-actions-nvim = callPackage ./gh-actions-nvim.nix {
    inherit buildVimPlugin;
  };
  fugit2-nvim = callPackage ./fugit2-nvim.nix {
    inherit buildVimPlugin;
  };
  codesnap-nvim = callPackage ./codesnap-nvim.nix {
    inherit buildVimPlugin;
  };
}
