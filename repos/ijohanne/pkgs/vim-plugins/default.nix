{ pkgs, sources }:
{
  git-blame-nvim = import ./git-blame-nvim { inherit pkgs sources; };
  language-tool-nvim = import ./language-tool-nvim { inherit pkgs sources; };
  nvim-lspconfig = import ./nvim-lspconfig { inherit pkgs sources; };
  nvim-lsp-extensions = import ./nvim-lsp-extensions { inherit pkgs sources; };
  nvim-web-devicons = import ./nvim-web-devicons { inherit pkgs sources; };
  ranger-nvim = import ./ranger-vim { inherit pkgs sources; };
  nvim-treesitter = import ./nvim-treesitter { inherit pkgs sources; };
  nvim-treesitter-textobjects = import ./nvim-treesitter-textobjects { inherit pkgs sources; };
  nvim-treesitter-refactor = import ./nvim-treesitter-refactor { inherit pkgs sources; };
  nvim-treesitter-angular = import ./nvim-treesitter-angular { inherit pkgs sources; };
  nvim-tree-docs = import ./nvim-tree-docs { inherit pkgs sources; };
  bubbly-nvim = import ./bubbly-nvim { inherit pkgs sources; };
  vim-signify = import ./vim-signify { inherit pkgs sources; };
  edge = import ./edge { inherit pkgs sources; };
  vim-hexokinase = import ./vim-hexokinase { inherit pkgs sources; };
}
