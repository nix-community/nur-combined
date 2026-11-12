{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "comfyui-workflow-mcp";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Silicon-AI-Garden-Ecosystem";
    repo = "comfyui-workflow-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JzLQC4hv7MsV6cCV+cc7r3fiTrcctPk/O+pdUXkH+Jw=";
  };

  cargoHash = "sha256-s1HAD6K1g1Nec3UBpDxJi8Ql8ZmVyGcNQMScGueRkMc=";

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
