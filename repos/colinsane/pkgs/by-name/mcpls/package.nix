{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mcpls";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "bug-ops";
    repo = "mcpls";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LEMcmr2+xxZnq0wKhql0jT6ma89tAD1J3hkUAeC1FXY=";
  };

  cargoHash = "sha256-ktQDIY5Q9DyymDIxUxTjzPugVc46Sn4GOP9+u9wfZlI=";

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
