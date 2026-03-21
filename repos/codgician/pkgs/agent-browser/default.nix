{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "agent-browser";
  version = "0.21.4";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T+IiizT1e5nuH6EqROn0b/w3H1OShWTTHUqD7tZJDkw=";
  };

  sourceRoot = "${finalAttrs.src.name}/cli";

  cargoHash = "sha256-E0QbXOC4h3MfYeDR+eSW9J4smnAPOf48PhmVK/pPZ+E=";

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
