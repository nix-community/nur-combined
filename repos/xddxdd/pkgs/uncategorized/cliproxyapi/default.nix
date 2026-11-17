{
  fetchFromGitHub,
  lib,
  buildGo127Module,
  nix-update-script,
}:
buildGo127Module (finalAttrs: {
  pname = "cliproxyapi";
  version = "8.0.76";
  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gQclqhFrw82upufHQ48+nHSPeA6N9gBwcsp1BlGC308=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-MlSvPcUOQsCwFo/SAn+L5aK2C6RoaPF5HGNlSvshbbQ=";

  proxyVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };
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
