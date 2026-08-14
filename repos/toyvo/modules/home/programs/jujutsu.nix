{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.jujutsu;
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

  config = lib.mkIf cfg.enable {
    programs.jujutsu.settings.aliases = {
      f = [
        "git"
        "fetch"
        "--all-remotes"
      ];
      fetch = [
        "git"
        "fetch"
        "--all-remotes"
      ];
      rbm = [
        "util"
        "exec"
        "--"
        "bash"
        "-c"
        ''jj git fetch --all-remotes && jj rebase "$@" -d main@origin''
        ""
      ];
      ai-describe = lib.mkIf cfg.aiDescribe.enable [
        "util"
        "exec"
        "--"
        "bash"
        "-c"
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
          PI_ARGS=()
          ${lib.optionalString (
            cfg.aiDescribe.provider != null
          ) "PI_ARGS+=(--provider ${lib.escapeShellArg cfg.aiDescribe.provider})"}
          ${lib.optionalString (
            cfg.aiDescribe.model != null
          ) "PI_ARGS+=(--model ${lib.escapeShellArg cfg.aiDescribe.model})"}
          FULL_PROMPT=${lib.escapeShellArg cfg.aiDescribe.prompt}
          if [ -n "$EXTRA_CONTEXT" ]; then
            FULL_PROMPT="$EXTRA_CONTEXT"$'\n\n'"$FULL_PROMPT"
          fi
          # pi's plain print mode writes only the response text to stdout
          if ! MESSAGE=$(pi -p --no-session "''${PI_ARGS[@]}" "$FULL_PROMPT"$'\n\n'"$DIFF_OUTPUT"); then
            echo "Error: pi failed to generate a commit message" >&2
            exit 1
          fi
          # Flatten to one line, cap length, and trim whitespace
          MESSAGE=$(printf '%s' "$MESSAGE" | tr -d '\n' | head -c 500 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
          if [ -z "$MESSAGE" ]; then
            echo "Error: Failed to generate commit message" >&2
            exit 1
          fi
          jj describe -r "$CHANGE_ID" -m "$MESSAGE"
        ''
        ""
      ];
    };
  };
}
