{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  inherit (sources.cliproxyapi) pname version src;

  vendorHash = "sha256-uX7cezMFmHww0dmeNgUl2itn1JYbADQ485KjlYXsgeU=";

  proxyVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta = {
    changelog = "https://github.com/router-for-me/CLIProxyAPI/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Wrap Gemini CLI, Antigravity, ChatGPT Codex, Claude Code, Qwen Code, iFlow as an OpenAI/Gemini/Claude/Codex compatible API service";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "server";
  };
})
