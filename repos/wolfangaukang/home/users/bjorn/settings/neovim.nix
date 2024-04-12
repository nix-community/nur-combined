{ pkgs, dotfiles }:

{
  lspPackages = with pkgs; [
    # Bash
    nodePackages.bash-language-server

    # Docker
    nodePackages.dockerfile-language-server-nodejs

    # Lua
    lua-language-server

    # Nix
    nil

    # Python
    # TODO: See how to set up python-lsp-server
    nodePackages.pyright

    # YAML
    nodePackages.yaml-language-server

    # Rust
    rust-analyzer
  ];

  plugins = (with pkgs.vimPlugins; [
    # Treesitter
    (nvim-treesitter.withPlugins (plug: with plug; [
      tree-sitter-bash
      tree-sitter-comment
      tree-sitter-dockerfile
      tree-sitter-dot
      tree-sitter-java
      tree-sitter-json
      tree-sitter-json5
      tree-sitter-lua
      tree-sitter-markdown
      tree-sitter-markdown-inline
      tree-sitter-make
      tree-sitter-nix
      tree-sitter-php
      tree-sitter-python
      tree-sitter-rust
      tree-sitter-sql
      tree-sitter-toml
      tree-sitter-vim
      tree-sitter-yaml
    ]))

    # LSP
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = ''
        ${builtins.readFile "${dotfiles}/config/neovim/plugins/nvim-lspconfig.lua"}
        lspconfig.rust_analyzer.setup({
          settings = {
            ['rust-analyzer'] = {
              diagnostics = {
                enable = false;
              }
            }
          }
        })
      '';
    }

    # Nix
    vim-nix
    vim-nixhash

    # Markdown
    vim-markdown
    markdown-preview-nvim

    # Utils
    {
      plugin = nvim-spectre;
      type = "lua";
      config = builtins.readFile "${dotfiles}/config/neovim/plugins/nvim-spectre.lua";
    }
    {
      plugin = nvim-tree-lua;
      type = "lua";
      config = builtins.readFile "${dotfiles}/config/neovim/plugins/nvim-tree-lua.lua";
    }
    vim-better-whitespace
  ]);
}

