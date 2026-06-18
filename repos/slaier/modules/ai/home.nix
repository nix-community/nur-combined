{
  config,
  lib,
  pkgs,
  ...
}:
let
  rtkMD = pkgs.runCommand "claude-rtk-md" { } ''
    mkdir -p $out
    cp "${pkgs.rtk.src}/hooks/claude/rtk-awareness.md" $out/CLAUDE.md
  '';

  mkCluade =
    name:
    {
      key,
      base,
      model,
      haiku ? model,
      sonnet ? model,
      opus ? model,
    }:
    pkgs.writeShellApplication {
      name = "claude-${name}";
      runtimeInputs = [ pkgs.claude-code ];
      text = ''
        ANTHROPIC_AUTH_TOKEN=$(cat ${key})
        export ANTHROPIC_AUTH_TOKEN
        export ANTHROPIC_BASE_URL=${base};
        export ANTHROPIC_MODEL="${model}";
        export ANTHROPIC_DEFAULT_HAIKU_MODEL="${haiku}";
        export ANTHROPIC_DEFAULT_SONNET_MODEL="${sonnet}";
        export ANTHROPIC_DEFAULT_OPUS_MODEL="${opus}";

        export CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1
        exec claude --add-dir "${rtkMD}" "$@"
      '';
    };
in
{
  home.packages = with pkgs; [
    rtk
    (mkCluade "qwen" {
      key = writeText "dummy" "dummy";
      base = "http://127.0.0.1:8080";
      model = "preset/Qwen3.5-4B-MTP";
      haiku = "preset/Qwen3.5-4B-MTP";
      sonnet = "preset/Qwen3.5-4B-MTP";
    })
  ];
  programs.claude-code = {
    enable = true;

    configDir = "${config.xdg.configHome}/claude";

    settings = {
      statusLine = {
        type = "command";
        command = "${lib.getExe pkgs.ccometixline}";
      };
      hooks = {
        PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "rtk hook claude";
              }
            ];
          }
        ];
      };

      # Best-practice security boundaries:
      # - Auto-allow read-only Git commands
      # - Require explicit confirmation for commits, pushes, and generic Bash commands
      # - Strictly deny access to sensitive secrets and environment files
      permissions = {
        allow = [
          "Bash(git diff:*)"
          "Bash(git status:*)"
          "Bash(git log:*)"
        ];
        ask = [
          "Bash(git push:*)"
          "Bash(git commit:*)"
          "Bash(*)"
          "Edit"
          "WebFetch"
          "Write"
        ];
        deny = [
          "Read(./.env)"
          "Read(./secrets/**)"
          "Read(**/*.pem)"
          "Read(**/*.key)"
        ];
        defaultMode = "acceptEdits";
        disableBypassPermissionsMode = "disable";
      };
    };
  };
}
