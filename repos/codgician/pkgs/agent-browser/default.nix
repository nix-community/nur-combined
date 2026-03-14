{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo,
  rustc,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-04Y3OUiCfuIimO0KmF7VPFG3REvqD+nq7QprnuIZwKE=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/cli";
    hash = "sha256-7l/2Q1P5JIC+kp0Pm729LBXXHVDt//Xe1cieWHjcvdc=";
  };

  cargoRoot = "cli";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-NyqJMjG62A+95LgpLATUaTPa4LulRT25HOQUz9mRe/k=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
    pnpm_10
    pnpmConfigHook
    nodejs
    makeWrapper
  ];

  postUnpack = ''
    cargoDepsCopy="$sourceRoot/cli/vendor"
  '';

  buildPhase = ''
    runHook preBuild

    pnpm run build
    cargo build --release --manifest-path cli/Cargo.toml

    runHook postBuild
  '';

  # Upstream's postinstall.js downloads pre-built binaries from GitHub releases.
  # We build the Rust CLI from source instead, setting AGENT_BROWSER_HOME so
  # the CLI can locate dist/daemon.js at runtime.
  # skills/ contains AI agent documentation (SKILL.md) for tools like Claude Code.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/agent-browser
    cp -r dist node_modules package.json skills $out/lib/agent-browser/
    install -Dm755 cli/target/release/agent-browser $out/lib/agent-browser/agent-browser

    makeWrapper $out/lib/agent-browser/agent-browser $out/bin/agent-browser \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
      --set AGENT_BROWSER_HOME "$out/lib/agent-browser"

    runHook postInstall
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
