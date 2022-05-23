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
  options.my.home.vim = with lib.my; {
    enable = mkDisableOption "vim configuration";
  };

  config.programs.neovim = lib.mkIf cfg.enable {
    enable = true;
    # All the aliases
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Theming
      vim-gruvbox8 # Nice dark theme
      lualine-nvim # A lua-based status line
      lualine-lsp-progress # Show progress for LSP servers

      # tpope essentials
      vim-commentary # Easy comments
      vim-eunuch # UNIX integrations
      vim-fugitive # A 'git' wrapper
      vim-git # Sane git syntax files
      vim-repeat # Enanche '.' for plugins
      vim-rsi # Readline mappings
      vim-surround # Deal with pairs
      vim-unimpaired # Some ex command mappings
      vim-vinegar # Better netrw

      # Languages
      rust-vim
      vim-beancount
      vim-jsonnet
      vim-nix
      vim-pandoc
      vim-pandoc-syntax
      vim-toml

      # General enhancements
      vim-qf # Better quick-fix list

      # Other wrappers
      git-messenger-vim # A simple blame window

      # LSP and linting
      lsp_lines-nvim # Show diagnostics *over* regions
      null-ls-nvim # LSP integration for linters and formatters
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars)) # Better highlighting
      nvim-treesitter-textobjects # More textobjects
      nvim-ts-context-commentstring # Comment string in nested language blocks
      plenary-nvim # 'null-ls', 'telescope' dependency

      # Completion
      nvim-cmp # Completion engine
      cmp-buffer # Words from open buffers
      cmp-nvim-lsp # LSP suggestions
      cmp-nvim-lua # NeoVim lua API
      cmp-path # Path name suggestions
      cmp-under-comparator # Sort items that start with '_' lower
      friendly-snippets # LSP snippets collection
      luasnip # Snippet manager compatible with LSP

      # UX improvements
      dressing-nvim # Integrate native UI hooks with Telescope etc...
      gitsigns-nvim # Fast git UI integration
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
      shellcheck
      shfmt
    ];
  };

  config.xdg.configFile = lib.mkIf cfg.enable configFiles;
}
