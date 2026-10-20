{ lib, writeShellScriptBin, codex-desktop }:
(writeShellScriptBin "codex-computer-use" ''
  export NIRI_AGENT_LAUNCH=1
  exec ${codex-desktop}/opt/codex-desktop/resources/plugins/openai-bundled/plugins/unified-computer-use/bin/codex-computer-use-linux "$@"
'').overrideAttrs (_: {
  meta = {
    description = "MCP launcher for Codex Computer Use on niri";
    homepage = "https://github.com/lihaoze123/niri-computer-use";
    license = lib.licenses.mit;
    mainProgram = "codex-computer-use";
    platforms = [ "x86_64-linux" ];
  };
})
