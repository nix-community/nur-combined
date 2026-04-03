{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "agent-browser";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yzigwMfHuPnbZW6aas4cqXgvws9TLsjQlFR/VRmWNvw=";
  };

  sourceRoot = "${finalAttrs.src.name}/cli";

  cargoHash = "sha256-Uli2rITkoTxhrh34CrRPhslpViiYVkcuAjj/rSL5Ltk=";

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  __darwinAllowLocalNetworking = true;

  # skills/ contains SKILL.md for tools like Claude Code
  postInstall = ''
    mkdir -p $out/share/agent-browser
    cp -r ../skills $out/share/agent-browser/
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
