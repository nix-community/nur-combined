{
  lib,
  rustPlatform,

  sources,
  source ? sources.grok-search-rs,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  meta = {
    description = "Rust MCP server for Grok web search and Tavily-backed source retrieval";
    homepage = "https://github.com/Episkey-G/GrokSearch-rs";
    changelog = "https://github.com/Episkey-G/GrokSearch-rs/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "grok-search-rs";
  };
})
