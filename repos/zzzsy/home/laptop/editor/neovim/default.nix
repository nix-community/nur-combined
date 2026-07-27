{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.neovim = {
    enable = true;
    withPython3 = true;
    withNodeJs = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      wl-clipboard
      # general dependencies
      git
      lazygit
      ripgrep
      fzf
      fd
      tree-sitter # treesitter cli

      # LUA
      lua-language-server
      stylua

      # NIX
      nil
      nixfmt
      statix
    ];
    plugins = with pkgs.vimPlugins; [ lazy-nvim ];
    initLua =
      # lua
      let
        treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;

        treesitterGrammars = pkgs.symlinkJoin {
          name = "nvim-treesitter-grammars";
          paths = treesitter.dependencies;
        };

        plugins = with pkgs.vimPlugins; [
          blink-cmp
          bufferline-nvim
          conform-nvim
          flash-nvim
          friendly-snippets
          fzf-lua
          gitsigns-nvim
          grug-far-nvim
          lazydev-nvim
          lazy-nvim
          LazyVim
          lualine-nvim
          mini-ai
          mini-icons
          mini-pairs
          neo-tree-nvim
          noice-nvim
          nui-nvim
          nvim-lint
          nvim-lspconfig
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-ts-autotag
          persistence-nvim
          plenary-nvim
          snacks-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          ts-comments-nvim
          which-key-nvim
        ];

        mkEntryFromDrv =
          drv:
          if lib.isDerivation drv then
            {
              name = "${lib.getName drv}";
              path = drv;
            }
          else
            drv;
        lazyPath = pkgs.linkFarm "lazy-plugins" (map mkEntryFromDrv plugins);
      in
      #lua
      ''
        require("lazy").setup({
          defaults = {
            lazy = true,
          },
          dev = {
            path = "${lazyPath}",
            patterns = { "." },
            fallback = true,
          },
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            { "mason-org/mason-lspconfig.nvim", enabled = false },
            { "mason-org/mason.nvim", enabled = false },
            { import = "plugins" },
            { "neovim/nvim-lspconfig", opts = { servers = lsp_servers }},
            {
              "nvim-treesitter/nvim-treesitter",
              build = "",
              opts = {
                install_dir = "${treesitterGrammars}",
              },
            },
          },
          install = { colorscheme = { "everforest-nvim"} },
          checker = { enabled = false }
        })
      '';
  };

  xdg.configFile."nvim/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink ./lua;
    recursive = true;
  };
}
