{
  pkgs,
  buildVimPlugin,
  sources,
}:
{
  vim-pydocstring = pkgs.callPackage ./vim-pydocstring { inherit buildVimPlugin; };
  skkeleton = pkgs.callPackage ./skkeleton {
    inherit buildVimPlugin;
    source = sources.skkeleton;
  };
}
