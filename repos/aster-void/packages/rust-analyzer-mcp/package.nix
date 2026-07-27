{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rust-analyzer-mcp";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "zeenix";
    repo = "rust-analyzer-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-brnzVDPBB3sfM+5wDw74WGqN5ahtuV4OvaGhnQfDqM0=";
  };

  cargoHash = "sha256-7t4bjyCcbxFAO/29re7cjoW1ACieeEaM4+QT5QAwc34=";

  doCheck = false;

  meta = {
    description = "Model Context Protocol server that provides integration with rust-analyzer";
    longDescription = ''
      MCP server providing rust-analyzer integration with tools for symbols,
      definitions, references, hover, completion, formatting, code actions,
      and diagnostics for Rust projects.
    '';
    homepage = "https://github.com/zeenix/rust-analyzer-mcp";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "rust-analyzer-mcp";
  };
})
