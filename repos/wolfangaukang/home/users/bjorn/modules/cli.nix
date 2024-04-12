{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  inherit (inputs) self dotfiles;

  settings = {
    helix = import "${self}/home/users/bjorn/settings/helix.nix";
    neovim = import "${self}/home/users/bjorn/settings/neovim.nix" { inherit dotfiles pkgs; };
    fish = import "${self}/home/users/bjorn/settings/fish.nix" { inherit pkgs; };
  };

  cfg = config.defaultajAgordoj.cli;

  shellAliases = {
    ".." = "cd ..";
    "ed" = "$EDITOR";
  };

in
{
  options.defaultajAgordoj.cli = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables the CLI tools, plus the common Git, GPG, Neovim, Pass and SSH settings.
      '';
    };
    shell = {
      enableFish = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Enables the FISH shell
        '';
      };
      enableZsh = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enables ZSH shell
        '';
      };
    };
    editors = {
      helix = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Enables Helix editor
          '';
        };
        default = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Sets Helix as default editor (check https://github.com/helix-editor/helix/tree/master/runtime/themes)
          '';
        };
        theme = mkOption {
          default = "ayu_dark";
          type = types.str;
          description = ''
            Helix theme to use
          '';
        };
      };
      neovim = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Enables Neovim editor
          '';
        };
        default = mkOption {
          default = true;
          type = types.bool;
          description = ''
            Sets Neovim as default editor
          '';
        };
      };
    };
    enableTmux = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables TMUX.
      '';
    };
  };


  config = (mkIf cfg.enable (mkMerge [
    ({
      home.file = {
        ".xkb/symbols/colemak-bs_cl".source = "${dotfiles}/config/xkbmap/colemak-bs_cl";
        ".xkb/symbols/dvorak-bs_cl".source = "${dotfiles}/config/xkbmap/dvorak-bs_cl";
      };
    })
    (mkIf cfg.shell.enableZsh {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "docker" ];
          theme = "linuxonly";
        };
        shellAliases = shellAliases;
      };
    })
    (mkIf cfg.shell.enableFish {
      programs = {
        fish = {
          enable = true;
          shellAliases = shellAliases;
          plugins = settings.fish.plugins;
        };
        nix-index = {
          enable = true;
          enableFishIntegration = true;
        };
      };
    })
    (mkIf cfg.enableTmux {
      programs.tmux =
        let
          terminal = "screen-256color";
        in
        {
          enable = true;
          package = pkgs.tmux;
          clock24 = true;
          terminal = terminal;
          extraConfig = ''
            set-option -sa terminal-overrides ',${terminal}:RGB'
          '';
          # Neovim related (https://github.com/neovim/neovim/wiki/FAQ#esc-in-tmux-or-gnu-screen-is-delayed)
        } // (mkIf config.programs.neovim.enable { escapeTime = 10; });
    })
    (mkIf cfg.editors.helix.enable {
      programs.helix = {
        enable = true;
        defaultEditor = cfg.editors.helix.default;
        settings = settings.helix { theme = cfg.editors.helix.theme; };
      };
      home =
        let
          themeName = cfg.editors.helix.theme;
        in
        {
          file.".config/helix/themes/${themeName}.toml".source = "${pkgs.helix}/lib/runtime/themes/${themeName}.toml";
          packages = with pkgs; [
            # Bash
            nodePackages.bash-language-server
            # Markdown
            marksman
            # Nix
            nil
            # TOML
            taplo
            # YAML
            yaml-language-server
          ];
        };
    })
    (mkIf cfg.editors.neovim.enable {
      programs.neovim = {
        enable = true;
        defaultEditor = cfg.editors.neovim.default;
        package = pkgs.neovim-unwrapped;
        plugins = settings.neovim.plugins;
        viAlias = true;
        vimAlias = true;
        extraPackages = with pkgs; [
          # nvim-spectre
          gnused
          ripgrep

          # clipboard
          xclip
        ] ++ settings.neovim.lspPackages;
        # FIXME: Check my performance
        #extraConfig = builtins.readFile "${dotfiles}/config/neovim/init.vim";
      };
    })
  ]));

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
