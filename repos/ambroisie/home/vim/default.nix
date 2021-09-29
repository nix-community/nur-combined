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
      lightline-vim # Fancy status bar
      vim-gruvbox8 # Nice dark theme

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
      fastfold # Better folding
      vim-qf # Better quick-fix list

      # Other wrappers
      fzfWrapper # The vim plugin inside the 'fzf' package
      fzf-vim # Fuzzy commands
      git-messenger-vim # A simple blame window

      # LSP and linting
      ale # Asynchronous Linting Engine
      lightline-ale # Status bar integration
    ];

    extraConfig = builtins.readFile ./init.vim;
  };

  config.xdg.configFile = lib.mkIf cfg.enable configFiles;
}
