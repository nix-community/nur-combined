# docs:
# - <https://code.claude.com/docs/en/env-vars>
# - <https://code.claude.com/docs/en/cli-reference>
#
# useful flags/env:
# - `claude --bare` (or `CLAUDE_CODE_SIMPLE=1`): to not load CLAUDE.md, etc.  (but breaks auth?)
# - `CLAUDE_CODE_SHELL=bash`
# - `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=1`
# - `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose`
#
# how to use with self-hosted LLMs:
# - <https://unsloth.ai/docs/basics/claude-code#claude-code-tutorial>
#   ANTHROPIC_BASE_URL="http://localhost:8001"
#   ANTHROPIC_API_KEY='sk-no-key-required' ## or 'sk-1234'
#   add to ~/.claude.json:
#     "hasCompletedOnboarding": true
#     "primaryApiKey": "sk-dummy-key"
# - <https://docs.ollama.com/integrations/claude-code>
#   ANTHROPIC_AUTH_TOKEN=ollama
#   ANTHROPIC_API_KEY=""
#   ANTHROPIC_BASE_URL=http://localhost:11434
#
# using different hosted models:
#   `claude --model FOO`
#   ANTHROPIC_DEFAULT_OPUS_MODEL="anthropic/claude-opus-4.6"
#   ANTHROPIC_DEFAULT_SONNET_MODEL="anthropic/claude-sonnet-4.6"
#   ANTHROPIC_DEFAULT_HAIKU_MODEL="anthropic/claude-haiku-4.5"
#   CLAUDE_CODE_SUBAGENT_MODEL="anthropic/claude-opus-4.6"
{ config, pkgs, ... }:
{
  sane.programs.claude-code = {
    packageUnwrapped = pkgs.claude-code.overrideAttrs (prevAttrs: {
      makeWrapperArgs = (prevAttrs.makeWrapperArgs or []) ++ [
        "--set-default" "ANTHROPIC_BASE_URL" "http://${config.sane.hosts.by-name.desko.wg-home.ip}:11435"
        # XXX(2026-04-01): CLAUDE_CODE_ATTRIBUTION_HEADER=0 allegedly reduces randomness in the system prompt, making it more cacheable
        "--set-default" "CLAUDE_CODE_ATTRIBUTION_HEADER" "0"
        # XXX(2026-04-03): self-hosted models take >= 20s to reach first token, making it likely
        # that the first tool call will timeout at the default 20s
        "--set-default" "CLAUDE_CODE_GLOB_TIMEOUT_SECONDS" "120000"
        # "--set-default" "USE_BUILTIN_RIPGREP" "0"
        "--set-default" "DISABLE_TELEMETRY" "1"
        # this should disable the secondary "generate a title for this prompt" eval.
        "--set-default" "CLAUDE_CODE_DISABLE_TERMINAL_TITLE" "1"
        # CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
        # CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1  #< includes `DISABLE_TLEMETRY=1` + some others
        # CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK=1
        # CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=1
        # CLAUDE_STREAM_IDLE_TIMEOUT_MS=900000
        # DISABLE_INTERLEAVED_THINKING=1
        # ENABLE_TOOL_SEARCH=true
      ];
    });

    suggestedPrograms = [ "git" ];

    sandbox.net = "all";
    sandbox.whitelistPortal = [
      "OpenURI"  #< for initial browser-based auth
    ];
    sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      ".config/git"  #< it needs to know commiter name/email for `git commit` to work
    ];
    # sandbox.net = "vpn.wg-home";

    fs.".config/claude/claude.json".symlink.text = builtins.toJSON {
      # claude.json docs: <https://code.claude.com/docs/en/settings#global-config-settings>
      customApiKeyResponses = {
        approved = [
          "sk-dummy-key"
        ];
      };
      permissions = {
        # equivalent to `--dangerously-skip-permissions`, allegedly.
        defaultMode = "bypassPermissions";
      };
      primaryApiKey = "sk-dummy-key";
      hasCompletedOnboarding = true;
    };

    # fs.".local/share/claude/settings.json".symlink.text = builtins.toJSON {
    #   # settings.json docs: <https://code.claude.com/docs/en/settings#available-settings>
    #   effortLevel = "medium";
    #   model = lib.removeSuffix ".gguf" pkgs.mlModels.qwen3_5-9b-claude-4_6-opus-reasoning-distilled-v2-q4_k_m.name;  #< only 79616 context, but reliable & fast enough
    #   # model = lib.removeSuffix ".gguf" pkgs.mlModels.qwen3_5-9b-q4_k_m.name;  #< only 102k context, but reliable
    #   # model = lib.removeSuffix ".gguf" pkgs.mlModels.qwen3_5-9b-claude-4_6-opus-reasoning-distilled-q3_k_m.name;
    #   sandbox = {
    #     # N.B.: `sandbox` was originally seen in `settings.local.json`. dunno the difference with that.
    #     enabled = true;
    #     autoAllowBashIfSandboxed = true;
    #   };
    # };

    # $100B company SELLING TO DEVS can't even figure out how to follow XDG specs, what a glorious future.
    fs.".claude".symlink.target = ".local/share/claude";
    fs.".claude.json".symlink.target = ".config/claude/claude.json";  #< API keys, granted perms

    persist.byStore.ephemeral = [
      # ".local/share/claude"
      ".local/share/claude/cache"
      ".local/share/claude/file-history"
      ".local/share/claude/plugins"
      ".local/share/claude/projects"
    ];

    # persist.byStore.private = [
    #   ".config/claude"
    # ];
  };
}
