{ pkgs, ... }:
{
  home.sessionVariables = {
    LLAMACPP_API_KEY = "dummy";
  };
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "bearded-theme"
      "bearded-icons"
    ];
    extraPackages = with pkgs; [
      nil
    ];
    mutableUserDebug = false;
    mutableUserKeymaps = false;
    mutableUserSettings = false;
    userSettings = {
      auto_update = false;
      telemetry = {
        metrics = false;
      };
      theme = {
        mode = "dark";
        light = "Bearded Theme Milkshark Mint";
        dark = "Ayu Mirage";
      };
      icon_theme = {
        mode = "dark";
        dark = "Bearded Icons";
        light = "Bearded Icons";
      };
      title_bar = {
        show_onboarding_banner = false;
        show_sign_in = false;
      };
      colorize_brackets = true;
      load_direnv = "shell_hook";
      drag_and_drop_selection.enabled = false;
      show_whitespaces = "all";
      languages = {
        Nix = {
          language_servers = [ "nil" "!nixd" ];
        };
      };
      node = {
        path = "${pkgs.nodejs}/bin/node";
        npm_path = "${pkgs.nodejs}/bin/npm";
      };
      language_models = {
        openai_compatible = {
          "LLAMACPP" = {
            api_url = "http://127.0.0.1:8080/v1";
            available_models = [
              {
                "name" = "Qwen3.6-35B-A3B";
                "max_tokens" = 16384;
              }
              {
                "name" = "Jan-v3-4B-base-instruct";
                "max_tokens" = 32768;
              }
            ];
          };
        };
      };
      edit_predictions = {
        provider = "open_ai_compatible_api";
        open_ai_compatible_api = {
          api_url = "http://localhost:8080/v1/completions";
          model = "Jan-v3-4B-base-instruct";
          prompt_format = "qwen";
          max_output_tokens = 64;
        };
      };
    };
    mutableUserTasks = false;
  };
}
