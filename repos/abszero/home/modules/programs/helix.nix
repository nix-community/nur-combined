{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf singleton;
  cfg = config.abszero.programs.helix;
in

{
  options.abszero.programs.helix.enable = mkEnableOption "post-modern text editor";

  config.programs.helix = mkIf cfg.enable {
    enable = true;
    package = pkgs.steelix;
    defaultEditor = true;

    extraPackages = with pkgs; [ lsp-ai-chendesheng ];

    settings = {
      editor = {
        # UI
        line-number = "relative";
        bufferline = "multiple"; # Enable when there are multiple buffers
        color-modes = true; # Color the mode indicator
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
        auto-save.after-delay = {
          enable = true;
          timeout = 300;
        };
        trim-final-newlines = true;
        trim-trailing-whitespace = true;
        middle-click-paste = false;
      };

      keys = rec {
        normal = {
          # Movement
          home = "goto_first_nonwhitespace";
          A-f = "find_till_char";
          A-S-f = "till_prev_char";

          h = "no_op"; # move_char_left
          j = "no_op"; # move_visual_line_down

          # Selection
          A-e = "select_all_children";

          A-p = "no_op"; # select_prev_sibling
          A-o = "no_op"; # expand_selection
          A-S-i = "no_op"; # select_all_children

          # Editing
          S-g = ":diffg";

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
            x = ":exit";
            a = ":quit-all";
            S-q = ":quit!";
            S-x = ":exit!";
            S-a = ":quit-all!";
            h = "hsplit";

            S-left = "swap_view_left";
            S-down = "swap_view_down";
            S-up = "swap_view_up";
            S-right = "swap_view_right";

            s = "no_op"; # hsplit
            j = "no_op"; # jump_view_down
            k = "no_op"; # jump_view_up
            l = "no_op"; # jump_view_right
            C-h = "no_op"; # jump_view_left
            C-j = "no_op"; # jump_view_down
            C-k = "no_op"; # jump_view_up
            C-l = "no_op"; # jump_view_right
            S-h = "no_op"; # swap_view_left
            S-j = "no_op"; # swap_view_down
            S-k = "no_op"; # swap_view_up
            S-l = "no_op"; # swap_view_right
          };

          # Buffer mode
          k = {
            q = ":buffer-close";
            x = ":write-buffer-close";
            o = ":buffer-close-others";
            a = ":buffer-close-all";
            S-q = ":buffer-close!";
            S-x = ":write-buffer-close!";
            S-o = ":buffer-close-others!";
            S-a = ":buffer-close-all!";
          };
        };

        insert = {
          home = "goto_first_nonwhitespace";
          C-backspace = "delete_word_backward";
          C-del = "delete_word_forward";
        };

        select = normal;
      };
    };

    languages = {
      language = [
        {
          name = "astro";
          language-servers = [
            # "oxfmt"
            "tsgolint"
            "biome"
            "tailwindcss-language-server"
            "astro-ls"
            "ai"
          ];
        }
        {
          name = "bash";
          language-servers = [
            "bash-language-server"
            "ai"
          ];
        }
        {
          name = "clojure";
          language-servers = [
            "tailwindcss-language-server"
            "clojure-lsp"
            "ai"
          ];
        }
        {
          name = "css";
          language-servers = [
            "tailwindcss-language-server"
            "vscode-css-language-server"
            "ai"
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
          name = "html";
          language-servers = [
            "oxfmt"
            "biome"
            "ai"
          ];
        }
        {
          name = "javascript";
          language-servers = [
            "oxfmt"
            "tsgolint"
            "biome"
            "vscode-eslint-language-server"
            "tailwindcss-language-server"
            "typescript-language-server"
            "ai"
          ];
        }
        {
          name = "json";
          language-servers = [
            "oxfmt"
            "biome"
            "ai"
          ];
        }
        {
          name = "jsonc";
          language-servers = [
            "oxfmt"
            "biome"
            "ai"
          ];
        }
        {
          name = "jsx";
          language-servers = [
            "oxfmt"
            "tsgolint"
            "biome"
            "vscode-eslint-language-server"
            "tailwindcss-language-server"
            "typescript-language-server"
            "ai"
          ];
        }
        {
          name = "html";
          language-servers = [
            "oxfmt"
            "biome"
            "tailwindcss-language-server"
            "vscode-html-language-server"
            "ai"
          ];
        }
        {
          name = "markdown";
          language-servers = [
            "markdown-oxide"
            "ai"
          ];
        }
        {
          name = "nix";
          language-servers = [
            "nixd"
            "ai"
          ];
        }
        {
          name = "nu";
          language-servers = [
            "nu"
            "ai"
          ];
        }
        {
          name = "python";
          language-servers = [
            "ty"
            "ruff"
            "ai"
          ];
        }
        {
          name = "qml";
          language-servers = [
            "qmlls"
            "ai"
          ];
        }
        {
          name = "svelte";
          language-servers = [
            "oxfmt"
            "tsgolint"
            "biome"
            "tailwindcss-language-server"
            "svelteserver"
            "ai"
          ];
        }
        {
          name = "toml";
          language-servers = [
            "tombi"
            "ai"
          ];
        }
        {
          name = "typescript";
          language-servers = [
            "oxfmt"
            "tsgolint"
            "biome"
            "vscode-eslint-language-server"
            "tailwindcss-language-server"
            "typescript-language-server"
            "ai"
          ];
        }
        {
          name = "tsx";
          language-servers = [
            "oxfmt"
            "tsgolint"
            "biome"
            "vscode-eslint-language-server"
            "tailwindcss-language-server"
            "typescript-language-server"
            "ai"
          ];
        }
        {
          name = "vue";
          language-servers = [
            "oxfmt"
            "tsgolint"
            "biome"
            "vscode-eslint-language-server"
            "tailwindcss-language-server"
            "vue-language-server"
            "ai"
          ];
        }
        {
          name = "yaml";
          language-servers = [
            "yaml-language-server"
            "ai"
          ];
        }
      ];

      language-server = {
        oxfmt = {
          command = "oxfmt";
          args = [ "--lsp" ];
        };

        tsgolint = {
          command = "oxlint";
          args = [ "--lsp" ];
          options = {
            typeAware = true;
            # typeCheck = true;
          };
        };

        biome = {
          command = "biome";
          args = [ "lsp-proxy" ];
          options = {
            vcs = {
              enabled = true;
              clientKind = "git";
              useIgnoreFile = true;
            };
            javascript = {
              experimentalEmbeddedSnippetsEnabled = true;
              resolver.experimentalPnpmCatalogs = true;
            };
            html = {
              experimentalFullSupportEnabled = true;
              formatter.enabled = true;
            };
          };
        };

        vscode-eslint-language-server.command = "vscode-eslint-language-server";

        tailwindcss-language-server = {
          command = "tailwindcss-language-server";
          args = [ "--stdio" ];
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

        ai = {
          command = "lsp-ai";
          args = [ "--stdio" ];
          config = {
            memory.file_store = { };

            models = {
              "qwen3.8-27b" = {
                type = "open_ai";
                model = "qwen3.8-27b";
                # Endpoint configured in flake modules
                auth_token = "";
                max_requests_per_second = 1;
              };
              "gemma-4-12b-instruct" = {
                type = "open_ai";
                model = "gemma-4-12b-instruct";
                auth_token = "";
                max_requests_per_second = 1;
              };
            };

            completion = {
              model = "gemma-4-12b-instruct";
              parameters = {
                max_context = 12000;
                max_tokens = 2000;
                messages = [
                  {
                    role = "system";
                    content = "You are an expert code assistant who writes beautiful, concise and idiomatic code. Given the code that the user is writing, complete with your code or comment at cursor location `<CURSOR>`. Output ONLY your completion.";
                  }
                  {
                    role = "user";
                    content = "{CODE}";
                  }
                ];
              };
            };

            chat = singleton {
              action_display_name = "Chat";
              trigger = "!C";
              model = "qwen3.8-27b";
              parameters = {
                max_context = 18000;
                max_tokens = 8000;
                messages = singleton {
                  role = "system";
                  content = ''
                    You are an expert code assistant. Answer accurately the user's question given the code context:

                    ```
                    {CONTEXT}
                    ```
                  '';
                };
              };
            };

            diagnostic_actions = {
              model = "qwen3.8-27b";
              parameters = {
                max_context = 18000;
                max_tokens = 8000;
              };
              explanation_severity = 3; # Info
            };

            refactor_actions = {
              model = "qwen3.8-27b";
              parameters = {
                max_context = 18000;
                max_tokens = 8000;
              };
            };

            actions = singleton {
              action_display_name = "Complete";
              model = "qwen3.8-27b";
              parameters = {
                max_context = 18000;
                max_tokens = 8000;
                messages = [
                  {
                    role = "system";
                    content = "You are an expert code assistant who writes beautiful, concise and idiomatic code. Given the code that the user is writing, complete with your code or comment at cursor location `<CURSOR>`. Output ONLY your completion.";
                  }
                  {
                    role = "user";
                    content = "{CODE}";
                  }
                ];
              };
            };
          };
        };
      };
    };
  };
}
