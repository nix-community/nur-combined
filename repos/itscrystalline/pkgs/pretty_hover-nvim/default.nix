{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "pretty_hover-nvim";
  version = "a421246";

  src = fetchFromGitHub {
    owner = "Fildo7525";
    repo = "pretty_hover";
    rev = "a4212464431e534725e84357aae70a5311d7ea8c";
    hash = "sha256-5F+tQVgGIxMtjnXaIYJ9KSM5lwO2xeIC1Rj6awRuYzU=";
  };

  meta = with lib; {
    description = "A small and customizable Neovim plugin for pretty printing the hover information from LSP servers ";
    homepage = "https://github.com/Fildo7525/pretty_hover";
    license = licenses.mit;
    sourceProvenance = [sourceTypes.fromSource];
    maintainers = [];
  };
}
