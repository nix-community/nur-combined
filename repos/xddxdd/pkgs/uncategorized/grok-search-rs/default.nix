{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "grok-search-rs";
  version = "0.1.25";
  src = fetchFromGitHub {
    owner = "Episkey-G";
    repo = "GrokSearch-rs";
    tag = "v0.1.24";
    hash = "sha256-RbGspj/jQ/Z5VwUFFKegfJsRJn4AZcTQjczPngbDuUw=";
  };
  cargoHash = "sha256-zyIuQuYtiViv33VXIvMB3YQbacXIQdYaqjlBdHNYQUc=";

  postPatch = ''
    sed -i -E 's/^version = ".*"/version = "${finalAttrs.version}"/' Cargo.toml
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/Episkey-G/GrokSearch-rs/releases/tag/v${finalAttrs.version}";
    description = "Rust MCP server for Grok web search and Tavily-backed source retrieval";
    homepage = "https://github.com/Episkey-G/GrokSearch-rs";
    license = lib.licenses.mit;
    mainProgram = "grok-search-rs";
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
