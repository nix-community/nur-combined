{
  lib,
  hostConfig,
  ...
}:
let
  hiddenClaudeModels = [
    "claude-haiku-4-5"
    "claude-haiku-5-5"
    "claude-sonnet-4-6"
    "claude-sonnet-5"
    "claude-sonnet-5-5"
    "claude-opus-4-5"
    "claude-opus-4-6"
    "claude-opus-4-7"
    "claude-opus-4-8"
    "claude-opus-5"
    # "claude-opus-5-5"
    "claude-fable-5"
    "claude-fable-5-1"
    # "claude-fable-5-2"
  ];
  hiddenGptModels = [
    "gpt-5.2"
    "gpt-5.3-codex"
    "gpt-5.4-mini"
    "gpt-5.4"
    "gpt-5.5"
    "gpt-5.6-luna"
    "gpt-5.6-terra"
    "gpt-5.6-sol"
  ];
in
{
  programs.t3code = lib.optionalAttrs hostConfig.isGraphical {
    enable = true;

    clientSettings = {
      composerRichTextEnabled = false;
      confirmThreadArchive = true;
      confirmThreadDelete = true;
      diffWordWrap = false;
      followUpBehavior = "queue";
    };

    userSettings = {
      favorites = [
        # {
        #   provider = "claudeAgent";
        #   model = "claude-fable-5-2";
        # }
        # {
        #   provider = "claudeAgent";
        #   model = "claude-opus-5-5";
        # }
        {
          provider = "codex";
          model = "gpt-6.2-astra";
        }
        {
          provider = "codex";
          model = "gpt-6.2-sol";
        }
        {
          provider = "cursor";
          model = "grok-4.7";
        }
        # {
        #   provider = "cursor";
        #   model = "claude-opus-5-5";
        # }
        {
          provider = "cursor";
          model = "claude-fable-5-2";
        }
        {
          provider = "cursor";
          model = "gemini-4-argon";
        }
      ];
      providerModelPreferences = {
        codex.hiddenModels = hiddenGptModels ++ [
          "gpt-5.3-codex-spark"
          # "gpt-6-luna"
          "gpt-6-sol"
          "gpt-6-astra"
          "gpt-6.1-terra"
          "gpt-6.1-sol"
          # "gpt-6.2-sol"
          # "gpt-6.2-astra"
        ];
        claudeAgent.hiddenModels = hiddenClaudeModels;
        cursor.hiddenModels =
          hiddenClaudeModels
          ++ hiddenGptModels
          ++ [
            "claude-sonnet-4"
            "claude-sonnet-4-5"
            "gpt-5-mini"
            "gpt-5.1"
            "gpt-5.1-codex-mini"
            "gpt-5.1-codex-max"
            "gpt-5.2-codex"
            "gpt-5.4-nano"
            "composer-2"
            "composer-2.5"
            "deepseek-v41-flash-1017"
            "gemini-2.5-flash"
            "gemini-3-flash"
            "gemini-3.1-pro"
            "gemini-3.5-flash"
            "gemini-3.6-flash"
            "gemini-3.7-flash"
            "gemini-3.8-flash"
            "gemini-4-hydrogen"
            "gemini-4-carbon"
            "gemini-4-argon"
            # "gemini-4-neon"
            "kimi-k2.5"
            "kimi-k2.7-code"
            "kimi-k3"
            "glm-5.2"
            "glm-5p3-flash"
            "glm-5p3"
            "grok-build-0.1"
            "grok-4.3"
            "grok-4.5"
            "grok-4.6"
            # "grok-4.7"
            "muse-spark-1.3"
            "muse-wonder-1.0"
          ];
      };

      sidebarAutoSettleAfterDays = 7;
      defaultModelSelection = {
        instanceId = "codex";
        model = "gpt-6.2-sol";
        options = [
          {
            id = "reasoningEffort";
            value = "xhigh";
          }
          {
            id = "serviceTier";
            value = "default";
          }
        ];
      };

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
