{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.helix;
in

{
  options.abszero.programs.helix.enable = mkEnableOption "post-modern text editor";

  config.programs.helix = mkIf cfg.enable {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      helix-gpt
    ];

    settings = {
      editor = {
        # UI
        bufferline = "multiple"; # Enable when there are multiple buffers
        color-modes = true;
        file-picker.hidden = false;

        # Text area
        text-width = 80;
        rulers = [
          80
          100
        ];
        indent-guides = {
          render = true;
          character = "⎸"; # Default bar is in the middle
        };
        whitespace = {
          render = {
            tab = "all";
            nbsp = "all";
            nnbsp = "all";
          };
          characters.tabpad = " ";
        };
        end-of-line-diagnostics = "hint";
        lsp.display-inlay-hints = true;

        # Editing
        auto-save = {
          focus-lost = true;
          after-delay = {
            enable = true;
            timeout = 300;
          };
        };
        trim-final-newlines = true;
        trim-trailing-whitespace = true;
        middle-click-paste = false;
        smart-tab.supersede-menu = true; # Prioritize smart tab over tab menu naviguation
      };

      keys = {
        normal = {
          # Movement
          home = "goto_first_nonwhitespace";
          A-f = "find_till_char";
          A-S-f = "till_prev_char";

          h = "no_op"; # move_char_left
          j = "no_op"; # move_visual_line_down
          k = "no_op"; # move_visual_line_up

          # Selection
          A-e = "select_all_children";

          A-p = "no_op"; # select_prev_sibling
          A-o = "no_op"; # expand_selection
          A-S-i = "no_op"; # select_all_children

          # Space mode
          space = {
            w = "no_op"; # window mode
          };

          # Goto mode
          g = {
            s = "goto_line_start";

            h = "no_op"; # goto_line_start
            l = "no_op"; # goto_line_end
            n = "no_op"; # goto_next_buffer
            p = "no_op"; # goto_previous_buffer
            j = "no_op"; # move_line_down
            k = "no_op"; # move_line_up
          };

          # Unimpaired mode
          n = "@]";
          t = "@[";
          "]" = {
            b = "goto_next_buffer";
          };
          "[" = {
            b = "goto_previous_buffer";
          };

          # Window mode
          l = "@<C-w>";
          C-w = {
            S-left = "swap_view_left";
            S-down = "swap_view_down";
            S-up = "swap_view_up";
            S-right = "swap_view_right";

            h = "hsplit";

            j = "no_op"; # jump_view_down
            k = "no_op"; # jump_view_up
            l = "no_op"; # jump_view_right
            S-h = "no_op"; # swap_view_left
            S-j = "no_op"; # swap_view_down
            S-k = "no_op"; # swap_view_up
            S-l = "no_op"; # swap_view_right
            s = "no_op"; # hsplit
          };
        };

        insert = {
          home = "goto_first_nonwhitespace";
          C-backspace = "delete_word_backward";
          C-del = "delete_word_forward";
        };

        select = {
          # Movement
          home = "goto_first_nonwhitespace";
          A-f = "find_till_char";
          A-S-f = "till_prev_char";

          h = "no_op"; # move_char_left
          j = "no_op"; # move_visual_line_down
          k = "no_op"; # move_visual_line_up

          # Goto mode
          g = {
            s = "goto_line_start";

            h = "no_op"; # goto_line_start
            l = "no_op"; # goto_line_end
            n = "no_op"; # goto_next_buffer
            p = "no_op"; # goto_previous_buffer
            j = "no_op"; # move_line_down
            k = "no_op"; # move_line_up
          };
        };
      };
    };

    languages = {
      language = [
        {
          name = "bash";
          language-servers = [
            "bash-language-server"
            "gpt"
          ];
        }
        {
          name = "clojure";
          language-servers = [
            "clojure-lsp"
            "gpt"
          ];
        }
        {
          name = "css";
          language-servers = [
            "vscode-css-language-server"
            "gpt"
          ];
        }
        {
          name = "devicetree";
          file-types = [
            "dts"
            "dtsi"
            "keymap"
            "overlay"
          ];
        }
        {
          name = "javascript";
          language-servers = [
            "ts"
            "gpt"
          ];
        }
        {
          name = "json";
          language-servers = [
            "vscode-json-language-server"
            "gpt"
          ];
        }
        {
          name = "html";
          language-servers = [
            "vscode-html-language-server"
            "gpt"
          ];
        }
        {
          name = "markdown";
          language-servers = [
            "markdown-oxide"
            "gpt"
          ];
        }
        {
          name = "nix";
          language-servers = [
            "nixd"
            "gpt"
          ];
        }
        {
          name = "nu";
          language-servers = [
            "nu"
            "gpt"
          ];
        }
        {
          name = "python";
          language-servers = [
            "ty"
            "ruff"
            "gpt"
          ];
        }
        {
          name = "qml";
          language-servers = [
            "qmlls"
            "gpt"
          ];
        }
        {
          name = "toml";
          language-servers = [
            "tombi"
            "gpt"
          ];
        }
        {
          name = "typescript";
          language-servers = [
            "ts"
            "gpt"
          ];
        }
        {
          name = "vue";
          language-servers = [
            "vue-language-server"
            "gpt"
          ];
        }
        {
          name = "yaml";
          language-servers = [
            "yaml-language-server"
            "gpt"
          ];
        }
      ];

      language-server = {
        gpt = {
          command = "bash";
          # Use copilot by default
          # API key is provided in weathercold/_base.nix
          args = [
            "-c"
            "helix-gpt --handler \${HANDLER:-copilot}"
          ];
          environment.COPILOT_MODEL = "claude-opus-4.5";
        };
        nixd.config = {
          nixpkgs.expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }";
          options = {
            nixos.expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.nixos-fwdesktop.options";
            home-manager.expr = ''(builtins.getFlake (toString ./.)).homeConfigurations."weathercold@nixos-fwdesktop".options'';
            flake-parts.expr = "(builtins.getFlake (toString ./.)).debug.options";
            flake-parts2.expr = "(builtins.getFlake (toString ./.)).currentSystem.options";
          };
        };
      };
    };
  };
}
