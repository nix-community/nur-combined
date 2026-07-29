{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mcpls";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "bug-ops";
    repo = "mcpls";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aPneH1grDnubFo7C4+eec5FiclBMVTd7LPJOJR+xSqU=";
  };

  cargoHash = "sha256-sNmCkQIyWPjWBSkFJY+qyFQjT3P6PYLInMM0cG58Tb8=";

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