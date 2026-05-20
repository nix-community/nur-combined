{ config, pkgs, ... }:
{
  sops.secrets.anthropic_auth_token = { };
  programs.claude-code = {
    enable = true;

    package = pkgs.writeShellApplication {
      name = "claude-mimo";
      runtimeInputs = [ pkgs.claude-code ];
      text = ''
        ANTHROPIC_AUTH_TOKEN=$(cat ${config.sops.secrets.anthropic_auth_token.path})
        export ANTHROPIC_AUTH_TOKEN
        exec claude "$@"
      '';
    };

    configDir = "${config.xdg.configHome}/claude";

    settings = {
      env = {
        ANTHROPIC_BASE_URL = "https://token-plan-cn.xiaomimimo.com/anthropic";
        ANTHROPIC_MODEL = "mimo-v2.5-pro";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "mimo-v2.5-pro";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "mimo-v2.5-pro";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "mimo-v2.5-pro";
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
