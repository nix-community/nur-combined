{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.zsh.smart-suggestion;
in
{
  options.programs.zsh.smart-suggestion = {
    enable = lib.mkEnableOption "zsh smart-suggestion (AI-powered command suggestions)";

    package = lib.mkPackageOption pkgs.nur.repos.xyenon "zsh-smart-suggestion" { };

    keybinding = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "^o";
      description = "Keybinding to trigger suggestions.";
    };

    proxyMode = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      description = "Enable proxy mode for better context.";
    };

    historyLines = lib.mkOption {
      type = with lib.types; nullOr ints.positive;
      default = null;
      example = 20;
      description = "Number of history lines to send.";
    };

    sendContext = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      description = "Send shell context to AI.";
    };

    bufferLines = lib.mkOption {
      type = with lib.types; nullOr ints.positive;
      default = null;
      example = 100;
      description = "Number of shell buffer lines to send.";
    };

    systemPrompt = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "Custom system prompt.";
    };

    aiProvider = lib.mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "openai"
          "azure_openai"
          "anthropic"
          "gemini"
        ]);
      default = null;
      description = "AI provider to use. Auto-detected if not set.";
    };

    openai = {
      baseUrl = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "Custom OpenAI API base URL.";
      };
      model = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        example = "gpt-4o";
        description = "OpenAI model to use.";
      };
    };

    azureOpenai = {
      resourceName = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "Azure OpenAI resource name.";
      };
      deploymentName = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "Azure OpenAI deployment name.";
      };
      apiVersion = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "Azure OpenAI API version.";
      };
      baseUrl = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "Custom Azure OpenAI API base URL.";
      };
    };

    anthropic = {
      baseUrl = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "Custom Anthropic API base URL.";
      };
      model = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        example = "claude-3-opus-20240229";
        description = "Anthropic model to use.";
      };
    };

    gemini = {
      baseUrl = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "Custom Gemini API base URL.";
      };
      model = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        example = "gemini-1.5-pro";
        description = "Gemini model to use.";
      };
    };

    configFile = lib.mkOption {
      type = with lib.types; nullOr (either path str);
      default = null;
      example = lib.literalExpression "config.age.secrets.zsh-smart-suggestion-config.path";
      description = ''
        Use this to store sensitive information like API keys that should not
        be written to the Nix store.
      '';
    };
  };

  config = lib.mkIf (config.programs.zsh.enable && cfg.enable) {
    programs.zsh = {
      autosuggestion.enable = true;
      initContent =
        with config.lib.zsh;
        lib.mkOrder 750 ''
          SMART_SUGGESTION_BINARY="${cfg.package}/bin/smart-suggestion"
          SMART_SUGGESTION_AUTO_UPDATE=false
          ${lib.optionalString (cfg.keybinding != null) (define "SMART_SUGGESTION_KEY" cfg.keybinding)}
          ${lib.optionalString (cfg.proxyMode != null) (define "SMART_SUGGESTION_PROXY_MODE" cfg.proxyMode)}
          ${lib.optionalString (cfg.historyLines != null) (
            define "SMART_SUGGESTION_HISTORY_LINES" cfg.historyLines
          )}
          ${lib.optionalString (cfg.sendContext != null) (
            define "SMART_SUGGESTION_SEND_CONTEXT" cfg.sendContext
          )}
          ${lib.optionalString (cfg.bufferLines != null) (
            define "SMART_SUGGESTION_BUFFER_LINES" cfg.bufferLines
          )}
          ${lib.optionalString (cfg.systemPrompt != null) (
            define "SMART_SUGGESTION_SYSTEM_PROMPT" cfg.systemPrompt
          )}
          ${lib.optionalString (cfg.aiProvider != null) (
            define "SMART_SUGGESTION_AI_PROVIDER" cfg.aiProvider
          )}
          ${lib.optionalString (cfg.openai.baseUrl != null) (define "OPENAI_BASE_URL" cfg.openai.baseUrl)}
          ${lib.optionalString (cfg.openai.model != null) (define "OPENAI_MODEL" cfg.openai.model)}
          ${lib.optionalString (cfg.azureOpenai.resourceName != null) (
            define "AZURE_OPENAI_RESOURCE_NAME" cfg.azureOpenai.resourceName
          )}
          ${lib.optionalString (cfg.azureOpenai.deploymentName != null) (
            define "AZURE_OPENAI_DEPLOYMENT_NAME" cfg.azureOpenai.deploymentName
          )}
          ${lib.optionalString (cfg.azureOpenai.apiVersion != null) (
            define "AZURE_OPENAI_API_VERSION" cfg.azureOpenai.apiVersion
          )}
          ${lib.optionalString (cfg.azureOpenai.baseUrl != null) (
            define "AZURE_OPENAI_BASE_URL" cfg.azureOpenai.baseUrl
          )}
          ${lib.optionalString (cfg.anthropic.baseUrl != null) (
            define "ANTHROPIC_BASE_URL" cfg.anthropic.baseUrl
          )}
          ${lib.optionalString (cfg.anthropic.model != null) (define "ANTHROPIC_MODEL" cfg.anthropic.model)}
          ${lib.optionalString (cfg.gemini.baseUrl != null) (define "GEMINI_BASE_URL" cfg.gemini.baseUrl)}
          ${lib.optionalString (cfg.gemini.model != null) (define "GEMINI_MODEL" cfg.gemini.model)}
          ${lib.optionalString (cfg.configFile != null) (define "SMART_SUGGESTION_CONFIG" cfg.configFile)}
          source "${cfg.package}/share/zsh/plugins/zsh-smart-suggestion/smart-suggestion.plugin.zsh"
        '';
    };
  };
}
