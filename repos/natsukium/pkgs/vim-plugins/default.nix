{
  pkgs,
  buildVimPlugin,
}: {
  vim-pydocstring = pkgs.callPackage ./vim-pydocstring {inherit buildVimPlugin;};
}
