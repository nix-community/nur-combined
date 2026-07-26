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

  mkShellApp =
    {
      package,
      name ? package.meta.mainProgram,
      program ? package.meta.mainProgram,
      runtimeEnv ? null,
      runtimeEnvFile ? null,
      flags ? "",
    }:
    pkgs.writeShellApplication {
      inherit name runtimeEnv;
      derivationArgs.version = pkgs.claude-code.version;
      text =
        lib.optionalString (runtimeEnvFile != null) (
          lib.concatMapAttrsStringSep "" (name: value: ''
            ${name}="$(cat ${value})"
            export ${name}
          '') runtimeEnvFile
        )
        + ''
          exec ${lib.getExe' package program} ${flags} "$@"
        '';
    };
in
{
  home.packages = with pkgs; [
    free-claude-code
    rtk
  ];
  sops.secrets = {
    tavily = { };
    context7 = { };
    github = { };
  };
  programs.mcp = {
    enable = true;
    servers =
      let
        mcp-remote =
          flags:
          "${lib.getExe (
            pkgs.writeShellApplication {
              name = "mcp-remote";
              runtimeInputs = [ pkgs.nodejs ];
              text = ''
                npx -y mcp-remote ${flags}
              '';
            }
          )}";
      in
      {
        tavily = {
          enabled = true;
          env.TAVILY_API_KEY.file = config.sops.secrets.tavily.path;
          command = mcp-remote ''"https://mcp.tavily.com/mcp/?tavilyApiKey=$TAVILY_API_KEY"'';
        };
        context7 = {
          enabled = true;
          env.CONTEXT7_API_KEY.file = config.sops.secrets.context7.path;
          command = mcp-remote ''https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: $CONTEXT7_API_KEY"'';
        };
        github = {
          enable = true;
          env.GITHUB_PERSONAL_ACCESS_TOKEN.file = config.sops.secrets.github.path;
          command = "${lib.getExe pkgs.github-mcp-server}";
          args = [
            "stdio"
            "--tools"
            (lib.concatStringsSep "," [
              "get_file_contents"
              "get_repository_tree"
              "list_tags"
              "search_code"
            ])
          ];
        };
      };
  };
  programs.claude-code = {
    enable = true;

    package = mkShellApp {
      name = "my-claude";
      package = pkgs.free-claude-code;
      program = "fcc-claude";
      flags = "--add-dir ${rtkMD}";
      runtimeEnv = {
        CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD = "1";
        CLAUDE_CODE_ATTRIBUTION_HEADER = "0";
      };
    };

    configDir = "${config.xdg.configHome}/claude";

    enableMcpIntegration = true;

    skills = {
      playwright-cli = "${pkgs.playwright-cli}/lib/node_modules/@playwright/cli/skills/playwright-cli";
      grilling = "${pkgs.mattpocock-skills}/share/skills/grilling";
      tdd = "${pkgs.mattpocock-skills}/share/skills/tdd";
    };

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
          "WebSearch"
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
