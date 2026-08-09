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
    };
  };
}
