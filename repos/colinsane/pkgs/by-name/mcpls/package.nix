{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mcpls";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "bug-ops";
    repo = "mcpls";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VsAyNzQx1E1qLLmdjmuWOIPbACeDXVU6gIMwd5DPpPQ=";
  };

  cargoHash = "sha256-vYGUrjbcpmUkUEU7v69yTJNblInHx3S7too68s8J8NY=";

  dontUseCargoParallelTests = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Universal MCP to LSP bridge";
    longDescription = ''
      mcpls exposes Language Server Protocol capabilities as Model Context
      Protocol tools, enabling AI agents to access semantic code intelligence
      such as hover, go-to-definition, find-references, diagnostics, and
      workspace-wide symbol search.
    '';
    homepage = "https://github.com/bug-ops/mcpls";
    license = lib.licenses.mit;
    mainProgram = "mcpls";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
