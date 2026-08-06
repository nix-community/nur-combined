{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.gryph;
  jsonFormat = pkgs.formats.json {};
  yamlFormat = pkgs.formats.yaml {};

  localPackages = {
    gryph = (import ../../internal/discover.nix {inherit (pkgs) lib;}).package {
      inherit pkgs;
      name = "gryph";
    };
  };

  # Hook definitions aligned with upstream GenerateHooksConfig per agent.
  # The module intentionally does not validate gryph's own config keys, but
  # the hook payloads below must mirror what `gryph install` writes so that
  # `gryph status` recognizes the installation.

  # claude-code: merged into ~/.claude/settings.json ("hooks" key)
  claudeCodeHookTypes = [
    "PreToolUse"
    "PostToolUse"
    "PostToolUseFailure"
    "SessionStart"
    "SessionEnd"
    "Notification"
    "SubagentStart"
    "SubagentStop"
  ];
  claudeCodeMatcherTypes = ["PreToolUse" "PostToolUse" "PostToolUseFailure"];

  # gemini: merged into ~/.gemini/settings.json ("hooks" key)
  geminiHookTypes = [
    "BeforeTool"
    "AfterTool"
    "SessionStart"
    "SessionEnd"
    "Notification"
  ];
  geminiMatcherTypes = ["BeforeTool" "AfterTool"];

  # codex: standalone ~/.codex/hooks.json
  codexHookTypes = [
    "SessionStart"
    "PreToolUse"
    "PostToolUse"
    "UserPromptSubmit"
    "Stop"
  ];
  codexMatcherTypes = ["PreToolUse" "PostToolUse"];

  # cursor: standalone ~/.cursor/hooks.json (version 1)
  cursorHookTypes = [
    "preToolUse"
    "beforeShellExecution"
    "beforeMCPExecution"
    "beforeReadFile"
    "beforeTabFileRead"
    "beforeSubmitPrompt"
    "postToolUse"
    "postToolUseFailure"
    "afterFileEdit"
    "afterTabFileEdit"
    "afterShellExecution"
    "afterMCPExecution"
    "afterAgentResponse"
    "afterAgentThought"
    "sessionStart"
    "sessionEnd"
    "stop"
    "subagentStart"
    "subagentStop"
    "preCompact"
  ];

  # windsurf: standalone ~/.codeium/windsurf/hooks.json
  windsurfHookTypes = [
    "pre_read_code"
    "post_read_code"
    "pre_write_code"
    "post_write_code"
    "pre_run_command"
    "post_run_command"
    "pre_mcp_tool_use"
    "post_mcp_tool_use"
    "pre_user_prompt"
    "post_cascade_response"
    "post_setup_worktree"
  ];

  hookCommand = agent: hookType: "${cfg.hookCommand} _hook ${agent} ${hookType}";

  # Claude Code / Gemini style: { <hookType> = [ { matcher?; hooks = [ { type; command; } ]; } ]; }
  mkSettingsHooks = {
    agent,
    hookTypes,
    matcherTypes,
  }:
    lib.genAttrs hookTypes (hookType: [
      ({
          hooks = [
            {
              type = "command";
              command = hookCommand agent hookType;
            }
          ];
        }
        // lib.optionalAttrs (builtins.elem hookType matcherTypes) {matcher = "*";})
    ]);

  claudeCodeHooks = mkSettingsHooks {
    agent = "claude-code";
    hookTypes = claudeCodeHookTypes;
    matcherTypes = claudeCodeMatcherTypes;
  };

  geminiHooks = mkSettingsHooks {
    agent = "gemini";
    hookTypes = geminiHookTypes;
    matcherTypes = geminiMatcherTypes;
  };

  codexHooks = {
    hooks = lib.genAttrs codexHookTypes (hookType: [
      ({
          hooks = [
            {
              type = "command";
              command = hookCommand "codex" hookType;
              timeout = 30;
            }
          ];
        }
        // lib.optionalAttrs (builtins.elem hookType codexMatcherTypes) {matcher = "*";})
    ]);
  };

  cursorHooks = {
    version = 1;
    hooks = lib.genAttrs cursorHookTypes (hookType: [
      {command = hookCommand "cursor" hookType;}
    ]);
  };

  windsurfHooks = {
    hooks = lib.genAttrs windsurfHookTypes (hookType: [
      {command = hookCommand "windsurf" hookType;}
    ]);
  };

  substitutePlugin = file:
    pkgs.substitute {
      src = "${cfg.package}/share/gryph/${file}";
      substitutions = ["--replace-fail" "__GRYPH_COMMAND__" cfg.hookCommand];
    };

  mergeAgents = {
    claude-code = {
      path = ".claude/settings.json";
      enabled = cfg.enableIntegration.claude-code;
      hooks = claudeCodeHooks;
    };
    gemini = {
      path = ".gemini/settings.json";
      enabled = cfg.enableIntegration.gemini;
      hooks = geminiHooks;
    };
  };

  activationSpec = jsonFormat.generate "gryph-home-activation.json" {
    hookCommand = cfg.hookCommand;
    agents = mergeAgents;
    codex = {
      path = ".codex/config.toml";
      enabled = cfg.enableIntegration.codex;
    };
  };

  # Convergent merge/prune of gryph hooks into agent-owned config files.
  # Enabled integrations ensure their hooks are present; disabled ones have
  # their previously-installed gryph hooks removed again. Kept as a
  # standalone file so it can be linted and exercised directly.
  activationScript = ./gryph-home-integrations.py;
in {
  options.programs.gryph = {
    enable = lib.mkEnableOption "gryph, the local-first audit trail and observability tool for AI coding agents";

    package = lib.mkPackageOption localPackages "gryph" {
      pkgsText = "inputs.nur.repos.mzwing";
      extraDescription = "It is added to `home.packages` and invoked by every generated agent hook.";
    };

    hookCommand = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "gryph";
      example = "/nix/store/...-gryph-0.7.0/bin/gryph";
      description = ''
        Command used by every generated hook to invoke gryph. The default
        relies on `home.packages` putting gryph on `PATH`, matching upstream
        behavior so that `gryph status` recognizes the installation. Override
        it (e.g. with an absolute store path) only if your agents run in
        environments without the Home Manager session `PATH`; note that
        `gryph status`/`gryph doctor` then report the hooks as not
        configured, since they compare against the literal `gryph` command.
      '';
    };

    enableIntegration = {
      claude-code = lib.mkEnableOption "gryph hooks for Claude Code (merged into `~/.claude/settings.json`)";
      gemini = lib.mkEnableOption "gryph hooks for Gemini CLI (merged into `~/.gemini/settings.json`)";
      codex = lib.mkEnableOption "gryph hooks for Codex (`~/.codex/hooks.json` plus the `codex_hooks` feature flag in `~/.codex/config.toml`)";
      cursor = lib.mkEnableOption "gryph hooks for Cursor (`~/.cursor/hooks.json`)";
      windsurf = lib.mkEnableOption "gryph hooks for Windsurf (`~/.codeium/windsurf/hooks.json`)";
      opencode = lib.mkEnableOption "gryph plugin for OpenCode (`~/.config/opencode/plugins/gryph.js`)";
      pi-agent = lib.mkEnableOption "gryph extension for the Pi agent (`~/.pi/agent/extensions/gryph-hooks.ts`)";
    };

    settings = lib.mkOption {
      inherit (yamlFormat) type;
      default = {};
      example = lib.literalExpression ''
        {
          logging.level = "full";
          storage.retention_days = 30;
          privacy.sensitive_paths = ["**/work-secrets/**"];
          display.timezone = "utc";
        }
      '';
      description = ''
        Schema-agnostic configuration rendered verbatim to
        `~/.config/gryph/config.yaml`. The module neither enumerates nor
        validates gryph-specific keys; see
        <https://github.com/safedep/gryph#configuration> for the available
        options. The generated file is a read-only Nix store symlink, so
        `gryph config set` cannot modify it (this is expected); change this
        option instead. When empty, no config file is generated and gryph
        uses its built-in defaults.
      '';
    };

    hooks = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = {
        claude-code = claudeCodeHooks;
        gemini = geminiHooks;
        codex = codexHooks;
        cursor = cursorHooks;
        windsurf = windsurfHooks;
      };
      description = ''
        Generated hook configurations per agent, in exactly the shape
        `gryph install` would write them. Useful when the target settings
        file is already managed by another Home Manager module, e.g.
        `programs.claude-code.settings.hooks = config.programs.gryph.hooks.claude-code;`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile = lib.mkMerge [
      (lib.mkIf (cfg.settings != {}) {
        "gryph/config.yaml".source = yamlFormat.generate "gryph-config.yaml" cfg.settings;
      })
      (lib.mkIf cfg.enableIntegration.opencode {
        "opencode/plugins/gryph.js".source = substitutePlugin "plugin.js";
      })
    ];

    home.file = lib.mkMerge [
      (lib.mkIf cfg.enableIntegration.cursor {
        ".cursor/hooks.json".source = jsonFormat.generate "gryph-cursor-hooks.json" cursorHooks;
      })
      (lib.mkIf cfg.enableIntegration.windsurf {
        ".codeium/windsurf/hooks.json".source = jsonFormat.generate "gryph-windsurf-hooks.json" windsurfHooks;
      })
      (lib.mkIf cfg.enableIntegration.codex {
        ".codex/hooks.json".source = jsonFormat.generate "gryph-codex-hooks.json" codexHooks;
      })
      (lib.mkIf cfg.enableIntegration.pi-agent {
        ".pi/agent/extensions/gryph-hooks.ts".source = substitutePlugin "plugin.ts";
      })
    ];

    home.activation.gryphAgentIntegrations = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${pkgs.python3}/bin/python3 ${activationScript} ${activationSpec}
    '';
  };
}
