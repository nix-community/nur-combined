{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "direnv-nvim";
  version = "5641462";

  src = fetchFromGitHub {
    owner = "NotAShelf";
    repo = "direnv.nvim";
    rev = "564146278b3d5fe4ffa389cd103bab20f9b515d6";
    hash = "sha256-JbnGoZMApLtq4lSdGolcpKdsneolSOrzIi+O5yR2NDQ=";
  };

  meta = with lib; {
    description = "Lua implementation of direnv.vim for automatic .envrc handling & syntax. ";
    homepage = "https://github.com/NotAShelf/direnv.nvim";
    license = licenses.mpl20;
    sourceProvenance = [sourceTypes.fromSource];
    maintainers = [];
  };
}
