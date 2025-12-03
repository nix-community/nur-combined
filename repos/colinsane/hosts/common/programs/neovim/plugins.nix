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
      -- or \<Ctrl-k>, because `\` *already* shows keybinds (but only those under \)
      vim.api.nvim_set_keymap("n", "<Leader><C-k>", "", { callback=wk.show, desc = "show keybinds" })
    '';
  }
  {
    # LSP-capable code completion: <https://github.com/hrsh7th/nvim-cmp>
    # type half a symbol, then `Ctrl+Space` to show autocomplete options, then `Enter` to autocomplete it.
    # TODO: how to get incremental completion w/o requiring Ctrl+Space?
    plugin = nvim-cmp;
    config = ''
      local cmp = require("cmp")
      cmp.setup {
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          -- alternate mappings:
          --  ['<C-n>'] = cmp.mapping.select_next_item({
          --    behavior = cmp.SelectBehavior.Insert }
          --  ),
          --  ['<C-m>'] = cmp.mapping.select_prev_item({
          --    behavior = cmp.SelectBehavior.Insert }
          --  ),
          --  ['<C-e>'] = cmp.mapping.close(),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        }, {
          { name = 'buffer' },
        })
      }
    '';
  }
  {
    # used by nvim-cmp to find symbols in other buffers
    plugin = cmp-buffer;
  }
  {
    # used by nvim-cmp to find symbols in the LSP
    plugin = cmp-nvim-lsp;
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
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_nvim_lsp.default_capabilities()

    '' + lib.optionalString config.sane.programs.bash-language-server.enabled ''
      -- bash language server
      -- repo: <https://github.com/bash-lsp/bash-language-server>
      vim.lsp.config('bashls', {
        capabilities = capabilities,
        filetypes = { "bash", "sh", "zsh" },  -- defaults to just `sh`
        handlers = {
          -- the info and warnings are noisy and outright wrong most of the time
          -- so disable all diagnostics.
          -- source: <https://www.reddit.com/r/neovim/comments/13qurat/comment/jlk289u/>
          -- more: <https://github.com/neovim/nvim-lspconfig/issues/662>
          ['textDocument/publishDiagnostics'] = function() end
        },
      })
      vim.lsp.enable('bashls')

    '' + lib.optionalString config.sane.programs.clang-tools.enabled ''
      -- c/c++ language server
      vim.lsp.config('clangd', {
        capabilities = capabilities,
      })
      vim.lsp.enable('clangd')

    '' + lib.optionalString config.sane.programs.ltex-ls.enabled ''
      -- LaTeX / html / markdown spellchecker
      -- repo: <https://github.com/valentjn/ltex-ls>
      vim.lsp.config('ltex', {
        capabilities = capabilities,
      })
      vim.lsp.enable('ltex')

    '' + lib.optionalString config.sane.programs.lua-language-server.enabled ''
      -- Lua language server
      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('lua_ls')

    '' + lib.optionalString config.sane.programs.marksman.enabled ''
      -- Markdown language server
      -- repo: <https://github.com/artempyanykh/marksman>
      -- an alternative, specialized for PKMs: <https://github.com/Feel-ix-343/markdown-oxide>
      vim.lsp.config('marksman', {
        capabilities = capabilities,
      })
      vim.lsp.enable('marksman')

    '' + lib.optionalString config.sane.programs.nil.enabled ''
      -- nix language server
      -- repo: <https://github.com/oxalica/nil>
      -- features: <https://github.com/oxalica/nil/blob/main/docs/features.md>
      -- a newer alternative is `nixd`: <https://github.com/nix-community/nixd>
      vim.lsp.config('nil_ls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('nil_ls')

    '' + lib.optionalString config.sane.programs.nixd.enabled ''
      -- nix language server
      -- repo: <https://github.com/nix-community/nixd>
      -- this is a bit nicer than `nil`, noting things like redundant parens, unused args, ...
      vim.lsp.config('nixd', {
        capabilities = capabilities,
      })
      vim.lsp.enable('nixd')

    '' + lib.optionalString config.sane.programs.openscad-lsp.enabled ''
      -- openscad (.scad) language server
      -- repo: <https://github.com/Leathong/openscad-LSP>
      vim.lsp.config('openscad_lsp', {
        capabilities = capabilities,
      })
      vim.lsp.enable('openscad_lsp')

    '' + lib.optionalString config.sane.programs.pyright.enabled ''
      -- python language server
      vim.lsp.config('pyright', {
        capabilities = capabilities,
      })
      vim.lsp.enable('pyright')

    '' + lib.optionalString config.sane.programs.rust-analyzer.enabled ''
      -- Rust language server
      -- note: this requires `cargo`, and features are a bit eh...
      -- - thinks that `None` doesn't exist
      -- - can't autocomplete `std::` imports
      -- - but it CAN autocomplete stuff from non-std libraries (?)
      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
      })
      vim.lsp.enable('rust_analyzer')

    '' + lib.optionalString config.sane.programs.typescript-language-server.enabled ''
      -- Typescript language server
      -- repo: <https://github.com/typescript-language-server/typescript-language-server>
      -- requires tsconfig.json or jsconfig.json in the toplevel of the project directory
      vim.lsp.config('ts_ls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('ts_ls')

    '' + lib.optionalString config.sane.programs.vala-language-server.enabled ''
      -- Vala (gtk gui language) language server
      vim.lsp.config('vala_ls', {
        capabilities = capabilities,
      })
      vim.lsp.enable('vala_ls')
    '';
  }
  {
    # docs: fzf-vim (fuzzy finder): https://github.com/junegunn/fzf.vim
    # `:Rg <pattern>` to search the current directory and navigate to results
    # - or `:RG <pattern>` to re-launch `rg` on every keystroke (better results; slower)
    # - or `:Ag <pattern>`
    plugin = fzf-vim;
  }
  {
    # treesitter syntax highlighting: https://nixos.wiki/wiki/Tree_sitters
    # docs: https://github.com/nvim-treesitter/nvim-treesitter
    # config taken from: https://github.com/i077/system/blob/master/modules/home/neovim/default.nix
    # this is required for tree-sitter to even highlight
    # XXX(2024/06/03): `unison` removed because it doesn't cross compile (to armv7l-hf-multiplatform)
    plugin = nvim-treesitter.withPlugins (_: (lib.filter (p: p.pname != "unison-grammar") nvim-treesitter.allGrammars) ++ [
      # XXX: this is apparently not enough to enable syntax highlighting!
      # nvim-treesitter ships its own queries which may be distinct from e.g. helix.
      # the queries aren't included when i ship the grammar in this manner.
      # maybe check: <https://github.com/nvim-treesitter/nvim-treesitter/wiki/Extra-modules-and-plugins> ?
      #
      # however: tree-sitter for `#!nix-shell` is the WRONG APPROACH.
      # - because it works via "injection"s, i don't get proper LSP integration.
      #   i.e. no undefined variable checks, or language-aware function completions
      # upstream vim showed interest in a similar approach as mine, but w/o the tree-sitter integration:
      # - <https://groups.google.com/g/vim_dev/c/c-VXsJu-EKA>
      #   this likely still has the same problem w.r.t. LSP integration.
      # vim-nix project also has a solution:
      # - <https://github.com/LnL7/vim-nix/pull/51>
      #   this overrides the active filetype, so likely *is* what i want.
      # and i've implemented my own pure-lua .vimrc integration further below
      # pkgs.tree-sitter-nix-shell
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
    # detect `#!nix-shell -i $interpreter ...` files as filetype=$interpreter
    type = "lua";
    config = builtins.readFile ./nix_shell.lua;
  }
  {
    type = "viml";
    config = builtins.readFile ./source_nav.vim;
  }
  {
    # show commit which last modified text under the cursor.
    # trigger with `:GitMessenger` or `<Leader>gm` (i.e. `\gm`)
    plugin = git-messenger-vim;
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
    # source: <https://github.com/sunaku/vim-dasht>
    # search Dash/Zeal docsets with `:Dasht<Space><query>`
    plugin = vim-dasht;
    type = "viml";
    config = ''
      " query the word under the cursor: `\K` (in related docsets)
      nnoremap <silent> <Leader>K :call Dasht(dasht#cursor_search_terms())<Return>
      " input a string to query (in related docsets)
      nnoremap <Leader>k :Dasht<Space>
      " query *ALL* docsets with `\\k`
      nnoremap <Leader><Leader>k :Dasht!<Space>
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
