{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "grok-search-rs";
  version = "0.1.26";
  src = fetchFromGitHub {
    owner = "Episkey-G";
    repo = "GrokSearch-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1DiBg0P7iV+gbcNjrhayFMPRpJay/wQVnYi9lqrYJ+c=";
  };
  cargoHash = "sha256-4TIhpR6GFNKRd1O7Y8qJoj472d7Wbz2y37z3Y++bv/E=";

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
