{ pkgs
, neovim-pkg ? pkgs.neovim-unwrapped
, extra-plugins ? [ ]
}:

let
  defaultPlugins = (with pkgs.vimPlugins; [
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
      tree-sitter-sql
      tree-sitter-toml
      tree-sitter-vim
      tree-sitter-yaml
    ]))

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
      config = ''
        require("spectre").setup()
        vim.cmd([[
          command! Spectre lua require('spectre').open()
          command! SpectreVisual lua require('spectre').open_visual()
          command! SpectreCurrentFile lua require('spectre').open_file_search()
        ]])
      '';
    }
    {
      plugin = nvim-tree-lua;
      type = "lua";
      config = ''
        -- Taken from https://github.com/nvim-tree/nvim-tree.lua#setup
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        vim.opt.termguicolors = true
        require("nvim-tree").setup()
      '';
    }
  ]);

in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = neovim-pkg;
    plugins = defaultPlugins ++ extra-plugins; 
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # nvim-spectre
      gnused ripgrep
    ];
    extraConfig = ''
      set number
      " https://jdhao.github.io/2019/01/11/line_number_setting_nvim/
      augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
        autocmd BufLeave,FocusLost,InsertEnter *   set relativenumber!
      augroup END
    '';
  };
}
