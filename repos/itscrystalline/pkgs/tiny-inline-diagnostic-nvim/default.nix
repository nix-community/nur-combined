{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "tiny-inline-diagnostic-nvim";
  version = "147af4e";

  src = fetchFromGitHub {
    owner = "rachartier";
    repo = "tiny-inline-diagnostic.nvim";
    rev = "147af4e49f51dd48f41972de26552872b8ba7b25";
    hash = "sha256-LpZuRNGSK8AHLTIPIWoQlGot89qubFRL/RZ+EMs4bnQ=";
  };

  meta = with lib; {
    description = "A Neovim plugin for displaying inline diagnostic messages with customizable styles and icons. ";
    homepage = "https://github.com/rachartier/tiny-inline-diagnostic.nvim";
    license = licenses.mit;
    sourceProvenance = [sourceTypes.fromSource];
    maintainers = [];
  };
}
