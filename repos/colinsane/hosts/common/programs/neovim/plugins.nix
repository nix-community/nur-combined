{ config, lib, pkgs, ... }:
with pkgs.vimPlugins;
[
  {
    # <https://github.com/folke/which-key.nvim>
    # shows which keybindings trigger which actions.
    # Ctrl+k to show all keybingings.
    # e.g. hit `g`, and then 1000ms later you'll see a menu showing where in the file you can go
    # debug: `:checkhealth which-key`
    plugin = which-key-nvim;
    config = ''
      local wk = require("which-key")
      -- in "n"ormal mode, Ctrl+k will show all keybindings
      vim.api.nvim_set_keymap("n", "<C-k>", "", { callback=wk.show, desc = "show keybinds" })
    '';
  }
  {
    # Language Server Plugin config:
    # - <https://github.com/neovim/nvim-lspconfig>
    # - docs: `:help lspconfig`
    # - debug: `:LspInfo`
    #
    # usage:
    # - <C-x><C-o> for completion menu
    #   e.g. `os.path.<C-x><C-o>`  to show available os.path items in python
    plugin = nvim-lspconfig;
    config = ''
      local lspconfig = require("lspconfig")

    '' + lib.optionalString config.sane.programs.bash-language-server.enabled ''
      -- bash language server
      -- repo: <https://github.com/bash-lsp/bash-language-server>
      lspconfig.bashls.setup {
        filetypes = { "bash", "sh", "zsh" },  -- defaults to just `sh`
        handlers = {
          -- the info and warnings are noisy and outright wrong most of the time
          -- so disable all diagnostics.
          -- source: <https://www.reddit.com/r/neovim/comments/13qurat/comment/jlk289u/>
          -- more: <https://github.com/neovim/nvim-lspconfig/issues/662>
          ['textDocument/publishDiagnostics'] = function() end
        },
      }

    '' + lib.optionalString config.sane.programs.clang-tools.enabled ''
      -- c/c++ language server
      lspconfig.clangd.setup { }

    '' + lib.optionalString config.sane.programs.ltex-ls.enabled ''
      -- LaTeX / html / markdown spellchecker
      -- repo: <https://github.com/valentjn/ltex-ls>
      lspconfig.ltex.setup { }

    '' + lib.optionalString config.sane.programs.lua-language-server.enabled ''
      -- Lua language server
      lspconfig.lua_ls.setup { }

    '' + lib.optionalString config.sane.programs.marksman.enabled ''
      -- Markdown language server
      -- repo: <https://github.com/artempyanykh/marksman>
      -- an alternative, specialized for PKMs: <https://github.com/Feel-ix-343/markdown-oxide>
      lspconfig.marksman.setup { }

    '' + lib.optionalString config.sane.programs.nil.enabled ''
      -- nix language server
      -- repo: <https://github.com/oxalica/nil>
      -- features: <https://github.com/oxalica/nil/blob/main/docs/features.md>
      -- a newer alternative is `nixd`: <https://github.com/nix-community/nixd>
      lspconfig.nil_ls.setup { }

    '' + lib.optionalString config.sane.programs.nixd.enabled ''
      -- nix language server
      -- repo: <https://github.com/nix-community/nixd>
      -- this is a bit nicer than `nil`, noting things like redundant parens, unused args, ...
      lspconfig.nixd.setup { }

    '' + lib.optionalString config.sane.programs.openscad-lsp.enabled ''
      -- openscad (.scad) language server
      -- repo: <https://github.com/Leathong/openscad-LSP>
      lspconfig.openscad_lsp.setup { }

    '' + lib.optionalString config.sane.programs.pyright.enabled ''
      -- python language server
      lspconfig.pyright.setup { }

    '' + lib.optionalString config.sane.programs.rust-analyzer.enabled ''
      -- Rust language server
      -- note: this requires `cargo`, and features are a bit eh...
      -- - thinks that `None` doesn't exist
      -- - can't autocomplete `std::` imports
      -- - but it CAN autocomplete stuff from non-std libraries (?)
      lspconfig.rust_analyzer.setup { }

    '' + lib.optionalString config.sane.programs.typescript-language-server.enabled ''
      -- Typescript language server
      -- repo: <https://github.com/typescript-language-server/typescript-language-server>
      -- requires tsconfig.json or jsconfig.json in the toplevel of the project directory
      lspconfig.tsserver.setup { }

    '' + lib.optionalString config.sane.programs.vala-language-server.enabled ''
      -- Vala (gtk gui language) language server
      lspconfig.vala_ls.setup { }
    '';
  }
  {
    # docs: fzf-vim (fuzzy finder): https://github.com/junegunn/fzf.vim
    plugin = fzf-vim;
  }
  {
    # treesitter syntax highlighting: https://nixos.wiki/wiki/Tree_sitters
    # docs: https://github.com/nvim-treesitter/nvim-treesitter
    # config taken from: https://github.com/i077/system/blob/master/modules/home/neovim/default.nix
    # this is required for tree-sitter to even highlight
    plugin = nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars ++ [
      # XXX: this is apparently not enough to enable syntax highlighting!
      # nvim-treesitter ships its own queries which may be distinct from e.g. helix.
      # the queries aren't included when i ship the grammar in this manner
      pkgs.tree-sitter-nix-shell
    ]);
    type = "lua";
    config = ''
      -- lifted mostly from readme: <https://github.com/nvim-treesitter/nvim-treesitter>
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
          -- disable treesitter on Rust so that we can use SyntaxRange
          -- and leverage TeX rendering in rust projects
          disable = { "rust", "tex", "latex" },
          -- disable = { "tex", "latex" },
          -- true to also use builtin vim syntax highlighting when treesitter fails
          additional_vim_regex_highlighting = false
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm"
          }
        },
        indent = {
          enable = true,
          disable = {}
        }
      }

      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
    '';
  }
  {
    # docs: tex-conceal-vim: https://github.com/KeitaNakamura/tex-conceal.vim/
    plugin = tex-conceal-vim;
    type = "viml";
    config = ''
      " present prettier fractions
      let g:tex_conceal_frac=1
    '';
  }
  {
    # source: <https://github.com/LnL7/vim-nix>
    # fixes auto-indent (incl tab size) when editing .nix files
    plugin = vim-nix;
  }
  {
    # docs: surround-nvim: https://github.com/ur4ltz/surround.nvim/
    # docs: vim-surround: https://github.com/tpope/vim-surround
    plugin = vim-surround;
  }
  {
    plugin = vim-SyntaxRange;
    type = "viml";
    config = ''
      " enable markdown-style codeblock highlighting for tex code
      autocmd BufEnter * call SyntaxRange#Include('```tex', '```', 'tex', 'NonText')
      " autocmd Syntax tex set conceallevel=2
    '';
  }
]
