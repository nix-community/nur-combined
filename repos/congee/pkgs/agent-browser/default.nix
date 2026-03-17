{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo,
  rustc,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  version = "0.20.14";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G6tLoTAtIW1x5Wrflf1E4kdhhZw1PaIZiw+gVvbj79A=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    sourceRoot = "${finalAttrs.src.name}/cli";
    hash = "sha256-Oq1EoTrH3arvnsa69RP5TZ3pF9bWG6pgU3GWh3CyoY0=";
  };

  cargoRoot = "cli";

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
    makeWrapper
  ];

  postUnpack = ''
    cargoDepsCopy="$sourceRoot/cli/vendor"
  '';

  buildPhase = ''
    runHook preBuild

    cargo build --release --manifest-path cli/Cargo.toml

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/agent-browser
    cp -r skills $out/lib/agent-browser/
    install -Dm755 cli/target/release/agent-browser $out/lib/agent-browser/agent-browser

    makeWrapper $out/lib/agent-browser/agent-browser $out/bin/agent-browser \
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
