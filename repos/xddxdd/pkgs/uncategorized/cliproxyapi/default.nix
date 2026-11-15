{
  fetchFromGitHub,
  lib,
  buildGo127Module,
  nix-update-script,
}:
buildGo127Module (finalAttrs: {
  pname = "cliproxyapi";
  version = "8.0.72";
  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-psUUxiNI2NnNsa/bAMKw+0+ksKvFhJ84V1OcbCafdQg=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-y8ebJwpCUXESpHzZhX5FzbG6P5RkUsed97Vs1ZNKXhA=";

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
