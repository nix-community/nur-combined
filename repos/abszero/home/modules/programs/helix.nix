{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.helix;
in

{
  options.abszero.programs.helix.enable = mkEnableOption "post-modern text editor";

  config.programs.helix = mkIf cfg.enable {
    enable = true;
    defaultEditor = true;

    settings = {
      editor = {
        text-width = 100;
        rulers = [
          100
          120
        ];
        bufferline = "multiple";

        lsp.display-inlay-hints = true;

        file-picker.hidden = false;

        auto-save = {
          focus-lost = true;
          after-delay = {
            enable = true;
            timeout = 300;
          };
        };

        whitespace = {
          render = {
            tab = "all";
            nbsp = "all";
            nnbsp = "all";
          };
          characters.tabpad = " ";
        };

        indent-guides = {
          render = true;
          character = "⎸"; # Default bar is in the middle
        };
      };

      keys = {
        normal = {
          # Movement
          home = "goto_first_nonwhitespace";

          # Selection
          A-n = "select_prev_sibling";
          A-e = "shrink_selection";
          A-i = "expand_selection";
          A-a = "select_next_sibling";

          A-S-e = "select_all_children";
          A-S-a = "select_all_siblings";

          A-p = "no_op"; # select_prev_sibling
          A-o = "no_op"; # expand_selection
          A-S-i = "no_op"; # select_all_children

          # Window
          n = "@<C-w>";
          C-w = {
            n = "jump_view_left";
            e = "jump_view_down";
            i = "jump_view_up";
            a = "jump_view_right";

            S-n = "swap_view_left";
            S-e = "swap_view_down";
            S-i = "swap_view_up";
            S-a = "swap_view_right";

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
      };
    };

    languages = {
      language = [
        {
          name = "devicetree";
          file-types = [
            "dts"
            "dtsi"
            "overlay"
            "keymap"
          ];
        }
      ];

      language-server.nixd = {
        config = {
          nixpkgs.expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }";
          options = {
            nixos.expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.nixos-redmibook.options";
            home-manager.expr = ''(builtins.getFlake (toString ./.)).homeConfigurations."weathercold@nixos-redmibook".options'';
            flake-parts.expr = "(builtins.getFlake (toString ./.)).debug.options";
            flake-parts2.expr = "(builtins.getFlake (toString ./.)).currentSystem.options";
          };
        };
      };
    };
  };
}
