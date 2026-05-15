{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "lsp-document-highlight-nvim";
  version = "a6bf150";

  src = fetchFromGitHub {
    owner = "akioweh";
    repo = "lsp-document-highlight.nvim";
    rev = "a6bf150e994aa56b8aecf0b242ca757c7ce7de1f";
    hash = "sha256-L41qTaJ4NKJ5TEEFB/6uOUQq1CB++oVgRiDuR7qoUo0=";
  };

  meta = with lib; {
    description = ''Snappy "cursor word" highlighting using modern mechanics for neovim'';
    homepage = "https://github.com/akioweh/lsp-document-highlight.nvim";
    license = licenses.mit;
    sourceProvenance = [sourceTypes.fromSource];
    maintainers = [];
  };
}
