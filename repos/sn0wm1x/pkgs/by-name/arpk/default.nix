{
  fetchFromGitHub,
  lib,
  makeWrapper,
  nodejs_22,
  pnpm_9,
  stdenvNoCC,
  testers,
}:
let
  pnpm = pnpm_9;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "arpk";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "moeru-ai";
    repo = "arpk";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-/3tPUwjzZ4U/1sRkMzppWVh26eQ7IAiVXXhho4rKYnw=";
  };

  nativeBuildInputs = [
    nodejs_22
    makeWrapper
    pnpm.configHook
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-T33el2V62BEgxtY9hXRCMdJdZWEYWm+x31bkylzPUzY=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/node_modules/arpk}
    cp -r {dist,node_modules} $out/lib/node_modules/arpk

    makeWrapper ${lib.getExe nodejs_22} $out/bin/arpk --add-flags $out/lib/node_modules/arpk/dist/index.js

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "Ollama as your translator, with DeepLX-compatible API";
    homepage = "https://github.com/moeru-ai/arpk";
    # changelog = "https://github.com/moeru-ai/arpk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "arpk";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = nodejs_22.meta.platforms;
  };
})
