{
  pkgs,
  buildVimPlugin,
  sources,
}:
{
  claudecode-nvim = pkgs.callPackage ./claudecode-nvim {
    inherit buildVimPlugin;
    source = sources.claudecode-nvim;
  };
  vim-edgemotion = pkgs.callPackage ./vim-edgemotion { inherit buildVimPlugin; };
  skkeleton = pkgs.callPackage ./skkeleton {
    inherit buildVimPlugin;
    source = sources.skkeleton;
  };
}
