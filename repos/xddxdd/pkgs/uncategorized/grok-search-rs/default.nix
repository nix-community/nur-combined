{
  sources,
  lib,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.grok-search-rs) pname version src;

  cargoHash = "sha256-7PnhPNpivvWu6LxEbd1XNlHPabTennL/HDXgVl3Iqzo=";

  postPatch = ''
    sed -i -E 's/^version = ".*"/version = "${finalAttrs.version}"/' Cargo.toml
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  meta = {
    changelog = "https://github.com/Episkey-G/GrokSearch-rs/releases/tag/v${finalAttrs.version}";
    description = "Rust MCP server for Grok web search and Tavily-backed source retrieval";
    homepage = "https://github.com/Episkey-G/GrokSearch-rs";
    license = lib.licenses.mit;
    mainProgram = "grok-search-rs";
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
