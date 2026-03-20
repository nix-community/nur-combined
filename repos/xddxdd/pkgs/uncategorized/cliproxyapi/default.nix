{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  inherit (sources.cliproxyapi) pname version src;

  vendorHash = "sha256-sGHY+UA+OLUjvx61iZ7b3d+MeC53v25IuOI1P0DSuvs=";

  proxyVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Wrap Gemini CLI, Antigravity, ChatGPT Codex, Claude Code, Qwen Code, iFlow as an OpenAI/Gemini/Claude/Codex compatible API service";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "server";
  };
})
