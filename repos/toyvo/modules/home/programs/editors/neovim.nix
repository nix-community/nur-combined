{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nvim;
in
{
  options.programs.nvim.enable = lib.mkEnableOption "Enable neovim";

  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      defaultEditor = true;
      settings.vim = {
        viAlias = true;
        vimAlias = true;

        # Must come before any mappings
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
          # Clear search highlights
          {
            key = "<Esc>";
            mode = "n";
            action = "<cmd>nohlsearch<CR>";
            desc = "Clear search highlights";
          }

          # Window navigation
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

          # Diagnostics
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

          # Telescope searches (kickstart.nvim style)
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

          # Terminal escape
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
              cmd = {"${lib.getExe pkgs.nil}"},
              settings = {
                ["nil"] = {
                  formatting = {
                    command = {"${lib.getExe pkgs.nixfmt}"},
                  },
                },
                ["nix"] = {
                  flake = {
                    autoArchive = true,
                  },
                },
              },
            }
          '';
        };

        theme = {
          enable = true;
          name = "catppuccin";
          style = config.catppuccin.flavor;
          transparent = true;
        };

        languages = {
          enableDAP = true;
          enableExtraDiagnostics = true;
          enableFormat = true;
          enableTreesitter = true;
          bash.enable = true;
          go.enable = true;
          lua.enable = true;
          markdown.enable = true;
          nix.enable = true;
          python.enable = true;
          rust.enable = true;
          ts.enable = true;
          yaml.enable = true;
        };

        utility.sleuth.enable = true;
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.blink-cmp.enable = true;
        autocomplete.blink-cmp.setupOpts.signature.enabled = true;
        binds.whichKey.enable = true;
        git.enable = true;
      };
    };
  };
}
