{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "comfyui-workflow-mcp";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Silicon-AI-Garden-Ecosystem";
    repo = "comfyui-workflow-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WoDYf/mUF3Xo+t5T11jYxI6vXoOv4Z83aMqGBVcZvD8=";
  };

  cargoHash = "sha256-aNLxvLcTt/hS9KjH272rW4Vyhjqdu8Bf6Fbdj4tWHsk=";

  doCheck = true;

  meta = {
    description = "A ComfyUI workflow MCP friendly to both humans and agents";
    homepage = "https://github.com/Silicon-AI-Garden-Ecosystem/comfyui-workflow-mcp";
    changelog = "https://github.com/Silicon-AI-Garden-Ecosystem/comfyui-workflow-mcp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ knightfemale ];
    mainProgram = "comfyui-workflow-mcp";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
