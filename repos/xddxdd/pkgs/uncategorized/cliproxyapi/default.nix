{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "cliproxyapi";
  version = "8.0.23";
  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7SDLiut4/+7uZr1Usaq887r7TZNPdJA6rwmrdzgxTXQ=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-ju7dRQIDvz/oHP5Y6y0hklEBNPzwrtWqSQ7cr51jwTY=";

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
