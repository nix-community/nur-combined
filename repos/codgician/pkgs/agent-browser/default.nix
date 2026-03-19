{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "agent-browser";
  version = "0.21.2";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IY12OxMQdJbqKrG4csvjoSB3XapQBxwUvY31rMSTp/8=";
  };

  sourceRoot = "${finalAttrs.src.name}/cli";

  cargoHash = "sha256-pAKLllj7qHUv4xeUJNcx4inNH3tGBEnhHfOP3iZBHDk=";

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  __darwinAllowLocalNetworking = true;

  postInstall = ''
    mkdir -p $out/lib/agent-browser
    cp -r ../skills $out/lib/agent-browser/
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "agent-browser";
  };
})
