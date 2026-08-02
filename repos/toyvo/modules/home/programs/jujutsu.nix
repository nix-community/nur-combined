{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.jujutsu.aiDescribe;
in
{
  options.programs.jujutsu.aiDescribe = {
    enable = lib.mkEnableOption "ai-describe alias for generating commit messages";

    prompt = lib.mkOption {
      type = lib.types.str;
      default = ''
        You are a commit message generator. Analyze the code diff below and output ONLY the commit message string - absolutely no other text.

        Requirements:
        - Use conventional commit format: type(scope): subject
        - Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
        - Subject: lowercase, imperative mood, max 50 chars
        - No quotes, no markdown, no explanations, no thinking
        - Do not output anything except the commit message itself
      '';
      description = "The prompt to send to the AI model for generating commit messages";
    };

    provider = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default provider for pi (e.g., 'openai', 'anthropic', 'google'). Uses pi default if null.";
    };

    model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default model for pi (e.g., 'gpt-4o', 'claude-3-5-sonnet'). Uses pi default if null.";
    };
  };

  config =
    let
      # Build the shell script for ai-describe alias
      aiDescribeScript =
        let
          # Pre-escape the prompt at Nix evaluation time
          escapedPrompt = lib.escapeShellArg cfg.prompt;
          providerArg = if cfg.provider != null then ''--provider "${cfg.provider}"'' else "";
          modelArg = if cfg.model != null then ''--model "${cfg.model}"'' else "";
        in
        ''
          if [ -n "$1" ]; then
            CHANGE_ID="$1"
          else
            CHANGE_ID="@"
          fi
          # Parse extra context flags
          EXTRA_CONTEXT=""
          shift 2>/dev/null || true
          while [ $# -gt 0 ]; do
            case "$1" in
              -C)
                if [ -n "$2" ]; then
                  EXTRA_CONTEXT="Add context: $2"
                  shift 2
                else
                  shift
                fi
                ;;
              *)
                shift
                ;;
            esac
          done
          DIFF_OUTPUT=$(jj diff -r "$CHANGE_ID" --no-pager 2>/dev/null)
          if [ -z "$DIFF_OUTPUT" ]; then
            echo "Error: No diff found for change $CHANGE_ID" >&2
            exit 1
          fi
          PI_ARGS="${providerArg} ${modelArg}"
          FULL_PROMPT=${escapedPrompt}
          if [ -n "$EXTRA_CONTEXT" ]; then
            FULL_PROMPT="''${EXTRA_CONTEXT}\\n\\n$FULL_PROMPT"
          fi
          MESSAGE=$(pi -p --no-session --mode json $PI_ARGS "$FULL_PROMPT\\n\\n$DIFF_OUTPUT" | jq -r 'select(.type == "message_end" and .message.role == "assistant") | .message.content[0].text' 2>/dev/null | head -c 500)
          # Clean up whitespace
          MESSAGE=$(echo "$MESSAGE" | tr -d '\\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
          if [ -z "$MESSAGE" ]; then
            echo "Error: Failed to generate commit message" >&2
            exit 1
          fi
          jj describe -r "$CHANGE_ID" -m "$MESSAGE"
        '';
    in
    lib.mkIf cfg.enable {
      programs.jujutsu.settings.aliases.ai-describe = [
        "util"
        "exec"
        "--"
        "sh"
        "-c"
        aiDescribeScript
        "sh"
      ];
    };
}
