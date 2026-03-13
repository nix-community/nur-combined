{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo,
  rustc,
  nodejs,
  pnpm_10,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tdPWbMcszqBhXj4IU3DPrxiY0/XozbPLXlO0UGrZsnQ=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/cli";
    hash = "sha256-HoV3rFnpo+wKYVSErnKcXQ+os9ark2xzj0oB3QERK3U=";
  };

  cargoRoot = "cli";

  pnpmDeps = pnpm_10.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-akW4F0fc4coU38x/og2fedKmTZ0wRyvmYzQbQCYn8VU=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
    pnpm_10
    pnpm_10.configHook
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

  meta = {
    description = "Browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "agent-browser";
  };
})
