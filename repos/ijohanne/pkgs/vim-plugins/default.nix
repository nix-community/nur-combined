{ pkgs, sources }:
{
  git-blame-nvim = import ./git-blame-nvim { inherit pkgs sources; };
  language-tool-nvim = import ./language-tool-nvim { inherit pkgs sources; };
  nvim-treesitter = import ./neovim-treesitter { inherit pkgs sources; };
  nvim-lspconfig = import ./nvim-lspconfig { inherit pkgs sources; };
  nvim-lsp-extensions = import ./nvim-lsp-extensions { inherit pkgs sources; };
  nvim-web-devicons = import ./nvim-web-devicons { inherit pkgs sources; };
  ranger-nvim = import ./ranger-vim { inherit pkgs sources; };
}
