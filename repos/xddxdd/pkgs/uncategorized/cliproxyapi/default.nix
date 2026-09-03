{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "cliproxyapi";
  version = "7.2.149";
  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B13kmOdTEOPv3Dl9DjuU0iwsTPa6XP1u/WLk3HaZz2o=";
  };
  vendorHash = "sha256-MmIrOmsPs/7IZsiSwMj4JKxP2wkgkfLINPEMtRxy3O8=";

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
