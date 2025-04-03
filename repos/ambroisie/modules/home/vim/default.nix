{ config, pkgs, lib, ... }:
let
  cfg = config.my.home.vim;
  configFiles =
    let
      toSource = directory: { source = ./. + "/${directory}"; };
      configureDirectory =
        name: lib.nameValuePair "nvim/${name}" (toSource name);
      linkDirectories =
        dirs: builtins.listToAttrs (map configureDirectory dirs);
    in
    linkDirectories [
      "after"
      "autoload"
      "ftdetect"
      "lua"
      "plugin"
    ];
in
{
  options.my.home.vim = with lib; {
    enable = my.mkDisableOption "vim configuration";
  };

  config.programs.neovim = lib.mkIf cfg.enable {
    enable = true;

    # This is the best editor
    defaultEditor = true;

    # All the aliases
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Theming
      gruvbox-nvim # Nice dark theme
      lualine-nvim # A lua-based status line
      lualine-lsp-progress # Show progress for LSP servers

      # tpope essentials
      vim-eunuch # UNIX integrations
      vim-fugitive # A 'git' wrapper
      vim-git # Sane git syntax files
      vim-repeat # Enanche '.' for plugins
      vim-rsi # Readline mappings
      vim-unimpaired # Some ex command mappings

      # Languages
      vim-beancount

      # General enhancements
      vim-qf # Better quick-fix list

      # Other wrappers
      git-messenger-vim # A simple blame window

      # LSP and linting
      nvim-lspconfig # Easy LSP configuration
      lsp-format-nvim # Simplified formatting configuration
      lsp_lines-nvim # Show diagnostics *over* regions
      none-ls-nvim # LSP integration for linters and formatters
      nvim-treesitter.withAllGrammars # Better highlighting
      nvim-treesitter-textobjects # More textobjects
      plenary-nvim # 'null-ls', 'telescope' dependency

      # Completion
      luasnip # Snippet manager compatible with LSP
      friendly-snippets # LSP snippets collection
      nvim-cmp # Completion engine
      cmp-async-path # More responsive path completion
      cmp-buffer # Words from open buffers
      cmp-nvim-lsp # LSP suggestions
      cmp-nvim-lua # NeoVim lua API
      cmp-under-comparator # Sort items that start with '_' lower
      cmp_luasnip # Snippet suggestions from LuaSnip

      # UX improvements
      dressing-nvim # Integrate native UI hooks with Telescope etc...
      gitsigns-nvim # Fast git UI integration
      nvim-surround # Deal with pairs, now in Lua
      oil-nvim # Better alternative to NetrW
      telescope-fzf-native-nvim # Use 'fzf' fuzzy matching algorithm
      telescope-lsp-handlers-nvim # Use 'telescope' for various LSP actions
      telescope-nvim # Fuzzy finder interface
      which-key-nvim # Show available mappings
    ];

    extraConfig = builtins.readFile ./init.vim;

    # Linters, formatters, etc...
    extraPackages = with pkgs; [
      # C/C++
      clang-tools

      # Nix
      nixpkgs-fmt

      # Shell
      bash-language-server
      shfmt

      # Generic
      typos-lsp
    ];
  };

  config.xdg.configFile = lib.mkIf cfg.enable configFiles;
}
