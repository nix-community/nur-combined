{
  source,
  lib,
  buildVimPlugin,
}:

buildVimPlugin {
  inherit (source) pname src;
  version = "unstable-${source.date}";

  dontBuild = true;

  meta = with lib; {
    description = "SKK implements for Vim/Neovim with denops.vim";
    homepage = "https://github.com/vim-skk/skkeleton";
    license = licenses.zlib;
  };
}
