{
  pkgs,
  lib,
  inputs ? { },
  nil,
  nixfmt,
  # Runtime tools for LSP and telescope
  git,
  ripgrep,
  fd,
  lua-language-server,
  rust-analyzer,
  typescript-language-server,
  bash-language-server,
  yaml-language-server,
  marksman,
  vscode-langservers-extracted,
  pyright,
  gopls,
}:

if inputs ? "nvf" then
  let
    nvfConfig = inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [
        {
          config.vim = {
            viAlias = true;
            vimAlias = true;

            luaConfigPre = ''
              vim.g.mapleader = " "
              vim.g.maplocalleader = " "
            '';

            lineNumberMode = "relNumber";
            undoFile.enable = true;
            searchCase = "smart";

            options = {
              tabstop = 2;
              softtabstop = 2;
              shiftwidth = 2;
              expandtab = true;
              cursorline = true;
              mouse = "a";
              scrolloff = 10;
              signcolumn = "yes";
              splitbelow = true;
              splitright = true;
              confirm = true;
              updatetime = 250;
              timeoutlen = 300;
            };

            luaConfigPost = ''
              vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
              vim.opt.list = true

              vim.api.nvim_create_autocmd('TextYankPost', {
                desc = 'Highlight when yanking text',
                group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
                callback = function()
                  vim.highlight.on_yank()
                end,
              })
            '';

            keymaps = [
              {
                key = "<Esc>";
                mode = "n";
                action = "<cmd>nohlsearch<CR>";
                desc = "Clear search highlights";
              }
              {
                key = "<C-h>";
                mode = "n";
                action = "<C-w><C-h>";
                desc = "Move focus to left window";
              }
              {
                key = "<C-j>";
                mode = "n";
                action = "<C-w><C-j>";
                desc = "Move focus to lower window";
              }
              {
                key = "<C-k>";
                mode = "n";
                action = "<C-w><C-k>";
                desc = "Move focus to upper window";
              }
              {
                key = "<C-l>";
                mode = "n";
                action = "<C-w><C-l>";
                desc = "Move focus to right window";
              }
              {
                key = "<leader>q";
                mode = "n";
                action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
                desc = "Open diagnostic [Q]uickfix list";
              }
              {
                key = "[d";
                mode = "n";
                action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
                desc = "Previous [D]iagnostic";
              }
              {
                key = "]d";
                mode = "n";
                action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
                desc = "Next [D]iagnostic";
              }
              {
                key = "<leader>sh";
                mode = "n";
                action = "<cmd>Telescope help_tags<CR>";
                desc = "[S]earch [H]elp";
              }
              {
                key = "<leader>sk";
                mode = "n";
                action = "<cmd>Telescope keymaps<CR>";
                desc = "[S]earch [K]eymaps";
              }
              {
                key = "<leader>sf";
                mode = "n";
                action = "<cmd>Telescope find_files<CR>";
                desc = "[S]earch [F]iles";
              }
              {
                key = "<leader>ss";
                mode = "n";
                action = "<cmd>Telescope builtin<CR>";
                desc = "[S]earch [S]elect Telescope";
              }
              {
                key = "<leader>sw";
                mode = "n";
                action = "<cmd>Telescope grep_string<CR>";
                desc = "[S]earch current [W]ord";
              }
              {
                key = "<leader>sg";
                mode = "n";
                action = "<cmd>Telescope live_grep<CR>";
                desc = "[S]earch by [G]rep";
              }
              {
                key = "<leader>sd";
                mode = "n";
                action = "<cmd>Telescope diagnostics<CR>";
                desc = "[S]earch [D]iagnostics";
              }
              {
                key = "<leader>sr";
                mode = "n";
                action = "<cmd>Telescope resume<CR>";
                desc = "[S]earch [R]esume";
              }
              {
                key = "<leader>s.";
                mode = "n";
                action = "<cmd>Telescope oldfiles<CR>";
                desc = "[S]earch Recent Files";
              }
              {
                key = "<leader><leader>";
                mode = "n";
                action = "<cmd>Telescope buffers<CR>";
                desc = "Find existing buffers";
              }
              {
                key = "<leader>/";
                mode = "n";
                action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
                desc = "Fuzzy search in current buffer";
              }
              {
                key = "<Esc><Esc>";
                mode = "t";
                action = "<C-\\><C-n>";
                desc = "Exit terminal mode";
              }
            ];

            lsp = {
              enable = true;
              lightbulb.enable = true;
              trouble.enable = true;
              lspconfig.sources.nix-lsp = lib.mkForce ''
                lspconfig.nil_ls.setup{
                  capabilities = capabilities,
                  on_attach = default_on_attach,
                  cmd = {"${lib.getExe nil}"},
                  settings = {
                    ["nil"] = {
                      formatting = {
                        command = {"${lib.getExe nixfmt}"},
                      },
                      nix = {
                        flake = {
                          autoArchive = true,
                        },
                      },
                    },
                  },
                }
              '';
            };

            theme = {
              enable = true;
              name = "catppuccin";
              style = "frappe";
              transparent = true;
            };

            languages = {
              enableDAP = true;
              enableExtraDiagnostics = true;
              enableFormat = true;
              enableTreesitter = true;
              bash.enable = true;
              css.enable = true;
              go.enable = true;
              html.enable = true;
              lua.enable = true;
              markdown.enable = true;
              nix.enable = true;
              python.enable = true;
              rust.enable = true;
              typescript.enable = true;
              yaml.enable = true;
            };

            utility.sleuth.enable = true;
            statusline.lualine.enable = true;
            telescope.enable = true;
            autocomplete.blink-cmp = {
              enable = true;
              setupOpts = {
                signature.enabled = true;

                completion = {
                  list.selection = {
                    preselect = false;
                    auto_insert = false;
                  };
                  list.cycle = {
                    from_bottom = true;
                    from_top = true;
                  };
                  ghost_text = {
                    enabled = true;
                    show_with_selection = true;
                    show_without_selection = false;
                    show_with_menu = true;
                    show_without_menu = false;
                  };
                };

                keymap = {
                  preset = "super-tab";
                  "<CR>" = [
                    "accept"
                    "fallback"
                  ];
                };
              };
            };
            binds.whichKey.enable = true;
            git.enable = true;
          };
        }
      ];
    };
  in

  lib.mkWrappedProgram pkgs {
    name = "toyvo-neovim";
    package = nvfConfig.neovim;
    binaryName = "nvim";
    runtimeDeps = [
      git
      ripgrep
      fd
      nil
      nixfmt
      lua-language-server
      rust-analyzer
      typescript-language-server
      bash-language-server
      yaml-language-server
      marksman
      vscode-langservers-extracted
      pyright
      gopls
    ];
    extraBinaries = [
      "vi"
      "vim"
    ];
  }
else
  null
