{
  lib,
  hostConfig,
  ...
}:
{
  programs.t3code = lib.optionalAttrs hostConfig.isGraphical {
    enable = true;

    clientSettings = {
      settings = {
        confirmThreadArchive = true;
        confirmThreadDelete = true;
        diffWordWrap = false;
        favorites = [
          {
            provider = "claudeAgent";
            model = "claude-fable-5";
          }
          {
            provider = "claudeAgent";
            model = "claude-opus-5";
          }
          # {
          #   provider = "codex";
          #   model = "gpt-5.5";
          # }
          {
            provider = "cursor";
            model = "composer-2.5";
          }
          {
            provider = "cursor";
            model = "cursor-grok-4.5";
          }
          {
            provider = "cursor";
            model = "gpt-5.6-sol";
          }
          {
            provider = "cursor";
            model = "kimi-k3";
          }
        ];
        providerModelPreferences = {
          codex.hiddenModels = [
            "gpt-5.2"
            "gpt-5.3-codex"
            "gpt-5.4-mini"
            "gpt-5.4"
            "gpt-5.5"
            # "gpt-5.6-luna"
            "gpt-5.6-terra"
            # "gpt-5.6-sol"
          ];
          claudeAgent.hiddenModels = [
            "claude-haiku-4-5"
            "claude-sonnet-4-6"
            "claude-sonnet-5"
            "claude-opus-4-6"
            "claude-opus-4-5"
            "claude-opus-4-7"
            "claude-opus-4-8"
            # "claude-opus-5"
            # "claude-fable-5"
          ];
          cursor.hiddenModels = [
            "claude-haiku-4-5"
            "claude-sonnet-4"
            "claude-sonnet-4-5"
            "claude-sonnet-4-6"
            "claude-sonnet-5"
            "claude-opus-4-5"
            "claude-opus-4-6"
            "claude-opus-4-7"
            "claude-opus-4-8"
            # "claude-opus-5"
            "claude-fable-5"
            "gemini-2.5-flash"
            "gemini-3-flash"
            "gemini-3.1-pro"
            "gemini-3.5-flash"
            "gemini-3.6-flash"
            "kimi-k2.5"
            "kimi-k2.7-code"
            # "kimi-k3"
            "glm-5.2"
            "gpt-5-mini"
            "gpt-5.1"
            "gpt-5.1-codex-mini"
            "gpt-5.1-codex-max"
            "gpt-5.2"
            "gpt-5.2-codex"
            "gpt-5.3-codex"
            "gpt-5.4-nano"
            "gpt-5.4-mini"
            "gpt-5.4"
            "gpt-5.5"
            "gpt-5.6-luna"
            "gpt-5.6-terra"
            # "gpt-5.6-sol"
            "grok-build-0.1"
            "grok-4.3"
          ];
        };
      };
    };

    userSettings = {
      enableAssistantStreaming = true;
      providerInstances = {
        cursor = {
          driver = "cursor";
          enabled = true;
          config.binaryPath = "cursor-agent";
        };
        grok = {
          driver = "grok";
          enabled = false;
        };
        opencode = {
          driver = "opencode";
          enabled = false;
        };
      };
    };
  };
}
