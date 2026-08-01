{
  lib,
  pkgs,
  hostConfig,
  ...
}:

{
  programs.zed-editor = lib.optionalAttrs hostConfig.isGraphical {
    enable = true;
    mutableUserDebug = true;
    mutableUserKeymaps = true;
    mutableUserSettings = true;
    mutableUserTasks = true;
    extensions = [
      "asciidoc"
      "assembly"
      "docker-compose"
      "dockerfile"
      "elixir"
      "git-firefly"
      "html"
      "ini"
      "just"
      "kotlin"
      "log"
      "lua"
      "make"
      "material-icon-theme"
      "nix"
      "perl"
      "php"
      "rainbow-csv"
      "scss"
      "solidity"
      "sql"
      "terraform"
      "tokyo-night"
      "toml"
      "vue"
      "xml"
      "zig"
    ];
    extraPackages = with pkgs; [
      nixd
    ];
    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          "alt-shift-f" = "editor::Format";
        };
      }
      {
        bindings = {
          "cmd-shift-i" = "agent::Toggle";
        };
      }
    ];
    userSettings = {
      toolbar = {
        selections_menu = true;
        quick_actions = false;
        breadcrumbs = false;
      };
      auto_update = false;
      use_system_window_tabs = true;
      focus_follows_mouse = {
        enabled = false;
      };
      bottom_dock_layout = "left_aligned";
      tabs = {
        file_icons = true;
        git_status = true;
      };
      tab_bar = {
        show_pinned_tabs_in_separate_row = false;
        show_tab_bar_buttons = true;
        show_nav_history_buttons = false;
        show = true;
      };
      title_bar = {
        show_menus = false;
        show_user_picture = false;
        show_user_menu = true;
        show_sign_in = false;
        show_onboarding_banner = true;
        show_branch_name = true;
        show_branch_status_icon = false;
        show_project_items = true;
      };
      diagnostics = {
        button = true;
      };
      status_bar = {
        show_active_file = false;
        cursor_position_button = true;
        active_language_button = true;
      };
      collaboration_panel = {
        button = false;
      };
      git_panel = {
        dock = "left";
      };
      outline_panel = {
        dock = "left";
      };
      project_panel = {
        git_status_indicator = true;
        button = false;
        hide_root = true;
        scrollbar = {
          horizontal_scroll = true;
        };
        auto_reveal_entries = true;
        indent_size = 15.0;
        git_status = true;
        folder_icons = true;
        file_icons = true;
        entry_spacing = "standard";
        default_width = 240.0;
        dock = "left";
      };
      agent = {
        default_width = 500.0;
        dock = "right";
        sidebar_side = "right";
        favorite_models = [ ];
        model_parameters = [ ];
      };
      indent_guides = {
        coloring = "indent_aware";
        background_coloring = "indent_aware";
      };
      colorize_brackets = true;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      session = {
        trust_all_worktrees = true;
      };
      terminal = {
        button = false;
        show_count_badge = false;
        flexible = true;
        dock = "bottom";
        toolbar = {
          breadcrumbs = false;
        };
        cursor_shape = "bar";
        font_size = 14.0;
      };
      base_keymap = "Cursor";
      autosave = {
        after_delay = {
          milliseconds = 1000;
        };
      };
      buffer_font_fallbacks = [ "monospace" ];
      buffer_font_family = "CaskaydiaMono Nerd Font";
      tab_size = 2;
      agent_servers = {
        codex-acp = {
          type = "registry";
        };
        claude-acp = {
          type = "registry";
        };
        cursor = {
          type = "registry";
          favorite_config_option_values = {
            model = [
              "composer-2[fast=true]"
              "gpt-5.5[context=272k,reasoning=medium,fast=false]"
              "claude-opus-4-7[thinking=true,context=300k,effort=xhigh]"
            ];
          };
        };
      };
      icon_theme = "Material Icon Theme";
      ui_font_size = 16;
      buffer_font_size = 14.0;
      theme = {
        mode = "dark";
        light = "One Light";
        dark = "Tokyo Night Storm";
      };
      languages = {
        Nix.language_servers = [
          "nixd"
          "!nil"
        ];
      };
      # lsp = {
      #   nixd = {
      #     binary = {
      #       path = "${pkgs.nixd}/bin/nixd";
      #     };
      #   };
      # };
    };
  };
}
