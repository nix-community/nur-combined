{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.kreisys.bobthefish;
in {

  options.kreisys.bobthefish = {
    enable = mkEnableOption "Enable Bob the fish";
    defaultUser = mkOption {
      type = types.string;
      default = "root";
      description = "When this user is logged in, their username will not be displayed in the prompt.";
    };

    useNerdFonts = mkOption {
      type = types.bool;
      default = false;
      description = "Set to true if you have a nerd fonts patched font.";
    };

    colorScheme = mkOption {
      type = types.enum [
        "dark"
        "light"
        "solarized" "solarized-dark"
        "solarized-light"
        "base16" "base16-dark"
        "base16-light"
        "zenburn"
        "gruvbox"
        "dracula"

        "terminal" "terminal-dark" "terminal-dark-black"
        "terminal-dark-white"
        "terminal-light" "terminal-light-white"
        "terminal-light-black"

        "terminal2" "terminal2-dark" "terminal2-dark-black"
        "terminal2-dark-white"
        "terminal2-light" "terminal2-light-white"
        "terminal2-light-black"
      ];

      default = "base16";

      description = ''
        Available themes:

        > dark. The default bobthefish theme.
        > light. A lighter version of the default theme.
        > solarized (or solarized-dark), solarized-light. Dark and light variants of Solarized.
        > base16 (or base16-dark), base16-light. Dark and light variants of the default Base16 theme.
        > zenburn. An adaptation of Zenburn.
        > gruvbox. An adaptation of gruvbox.
        > dracula. An adaptation of dracula.

        Some of these may not look right if your terminal does not support 24 bit color, in which case you can try one of the terminal schemes (below). However, if you're using Solarized, Base16 (default), or Zenburn in your terminal and the terminal does support 24 bit color, the built in schemes will look nicer.

        There are several scheme that use whichever colors you currently have loaded into your terminal. The advantage of using the schemes that fall through to the terminal colors is that they automatically adapt to something acceptable whenever you change the 16 colors in your terminal profile.

        > terminal (or terminal-dark or terminal-dark-black)
        > terminal-dark-white. Same as terminal, but use white as the foreground color on top of colored segments (in case your colors are very dark).
        > terminal-light (or terminal-light-white)
        > terminal-light-black. Same as terminal-light, but use black as the foreground color on top of colored segments (in case your colors are very bright).
        For some terminal themes, like dark base16 themes, the path segments in the prompt will be indistinguishable from the background. In those cases, try one of the following variations; they are identical to the terminal schemes except for using bright black (brgrey) and dull white (grey) in the place of black and bright white.

        > terminal2 (or terminal2-dark or terminal2-dark-black)
        > terminal2-dark-white
        > terminal2-light (or terminal2-light-white)
        > terminal2-light-black
      '';
    };
  };

  config = mkIf cfg.enable {
    programs = {
      bash = {
        enable = true;
        interactiveShellInit = ''
          if [[ $SHLVL == 1 ]]; then
            exec fish
          fi
        '';
      };

      fish = {
        enable = true;
        promptInit = ''
          set -g default_user ${cfg.defaultUser}
          set -g theme_color_scheme ${cfg.colorScheme}
          set -g theme_nerd_fonts ${if cfg.useNerdFonts then "yes" else "no"}
        '';

        shellInit = ''
          set -gx PATH $HOME/.local/bin $PATH
          fish_vi_key_bindings
          function fish_user_key_bindings
            for mode in insert default visual
              bind -M $mode \cf forward-char
              bind -M $mode \ca beginning-of-line
              bind -M $mode \cx end-of-line
            end
          end
        '';
      };
    };

    environment = {
      systemPackages = with pkgs.nur.repos.kreisys.fishPlugins; [ iterm2-integration bobthefish completions.docker completions.docker-compose pkgs.git ];
      shells = [
        "/run/current-system/sw/bin/fish"
        "/var/run/current-system/sw/bin/fish"
        "${pkgs.fish}/bin/fish"
      ];
    };
  };
}
