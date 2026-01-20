{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo,
  rustc,
  nodejs,
  pnpm,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7KrZcgyCmyvdMxOQMiPkPzA1Ywu85X6b2n/3R8SYVmo=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/cli";
    hash = "sha256-Zw6n2DYE+ysCkLv40hidoAz2wZ1DBhL484FF/ZoSpww=";
  };

  cargoRoot = "cli";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 2;
    hash = "sha256-BczyzgK1xdecqsmcWKcWpsD/vIxFHWa6yu+lpmHdFdc=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
    pnpm
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/agent-browser/bin

    cp -r dist $out/lib/agent-browser/
    cp -r node_modules $out/lib/agent-browser/
    cp package.json $out/lib/agent-browser/

    install -Dm755 cli/target/release/agent-browser $out/lib/agent-browser/bin/agent-browser

    makeWrapper $out/lib/agent-browser/bin/agent-browser $out/bin/agent-browser \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
      --set AGENT_BROWSER_HOME "$out/lib/agent-browser"

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "agent-browser";
  };
})
